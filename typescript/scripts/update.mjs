// `cvdesk update`: downloads the newest version of this project from GitHub and
// installs it over this folder, without touching your own files (my-scripts/,
// .env). It takes the latest GitHub release, or the main branch if the project
// has no releases.
// - Every file it replaces or removes is saved in previous-version/ first.
// - If you changed one of the examples, your version is moved to my-scripts/.
// `cvdesk update --from <file>` installs a .zip or .tar.gz of the project you
// downloaded yourself, for example from GitHub's "Download ZIP".
// Plain JavaScript run with node (not tsx), since it may reinstall node_modules.
import { spawnSync } from "node:child_process";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import {
    projectDir, myScriptsDir, backupDir,
    listProjectFiles, hashFile, hashProjectFiles, readInstalled, writeInstalled, freeName,
} from "./project-files.mjs";

const repo = "barchart/cv-desktop-api-starter";
const folderInRepo = "typescript";

const fail = (message) => {
    console.error(message);
    process.exit(1);
};
const isFile = (p) => fs.statSync(p, { throwIfNoEntry: false })?.isFile() ?? false;
const isDir = (p) => fs.statSync(p, { throwIfNoEntry: false })?.isDirectory() ?? false;

const args = process.argv.slice(2);
const fromIndex = args.indexOf("--from");
const tmp = fs.mkdtempSync(path.join(os.tmpdir(), "cvdesk-update-"));
process.on("exit", () => fs.rmSync(tmp, { recursive: true, force: true }));

let archive, version, notes;
if (fromIndex >= 0) {
    const from = args[fromIndex + 1];
    if (!from || !isFile(path.resolve(from))) fail("Usage: cvdesk update --from <downloaded .zip or .tar.gz file>");
    archive = path.resolve(from);
    version = `file ${path.basename(archive)}`;
} else {
    console.log("Checking for a new version...");
    const latest = await findLatest();
    if (readInstalled()?.version === latest.version) {
        console.log(`Already up to date (${latest.version}).`);
        process.exit(0);
    }
    console.log(`Downloading ${latest.version}...`);
    archive = path.join(tmp, "download.tar.gz");
    // The plain download link, which (unlike the API) doesn't count toward GitHub's hourly limit.
    const download = await get(`https://github.com/${repo}/archive/${latest.ref}.tar.gz`);
    if (!download.ok) fail(`Downloading failed: GitHub answered "${download.status} ${download.statusText}". Try again later.`);
    fs.writeFileSync(archive, Buffer.from(await download.arrayBuffer()));
    ({ version, notes } = latest);
}

const newDir = extract(archive);
const changes = install(newDir);
writeInstalled({ version, files: hashProjectFiles(newDir) });
report(changes);
if (changes.count > 0 || isDir(path.join(projectDir, "src"))) {
    // The setup script that just arrived: npm install, move old scripts out of src/.
    const setup = spawnSync(process.execPath, [path.join(projectDir, "scripts", "project-setup.mjs")], { stdio: "inherit" });
    if (setup.status !== 0) fail("\nThe files were updated, but setting them up failed. Run the setup script again.");
}
if (changes.count > 0) {
    console.log(`\nUpdated to ${version}.`);
    if (notes) console.log(`\nWhat's new:\n${notes}`);
}

// The latest release, or the newest commit on the main branch if there are no releases.
async function findLatest() {
    const release = await github("/releases/latest", { allow404: true });
    if (release) {
        const { tag_name, body } = await release.json();
        return { ref: tag_name, version: tag_name, notes: body?.trim() };
    }
    const sha = (await (await github("/commits/HEAD", { accept: "application/vnd.github.sha" })).text()).trim();
    return { ref: sha, version: `commit ${sha.slice(0, 7)}` };
}

async function get(url, headers = {}) {
    try {
        return await fetch(url, { headers: { "User-Agent": "cvdesk-update", ...headers } });
    } catch (error) {
        fail(`Could not reach GitHub (${error.cause?.message ?? error.message}). Check your internet connection and try again.`);
    }
}

async function github(pathname, { accept = "application/vnd.github+json", allow404 = false } = {}) {
    const response = await get(`https://api.github.com/repos/${repo}${pathname}`, { Accept: accept, "X-GitHub-Api-Version": "2022-11-28" });
    if (response.ok) return response;
    if (response.status === 404 && allow404) return undefined;
    if (response.status === 404) fail(`Could not find github.com/${repo}. Is the project still public?`);
    if (response.status === 403 || response.status === 429) {
        fail("GitHub is limiting update checks from your network right now. Try again in an hour.");
    }
    fail(`GitHub answered "${response.status} ${response.statusText}". Try again later.`);
}

// Unpacks the archive and returns the project folder inside it.
function extract(file) {
    const name = fromIndex >= 0 ? file : "The downloaded version";
    const out = path.join(tmp, "extracted");
    fs.mkdirSync(out);
    // Windows' own tar (also reads .zip); another tar earlier on PATH, such as Git's, may not.
    const tar = process.platform === "win32" ? path.join(process.env.SystemRoot ?? "C:\\Windows", "System32", "tar.exe") : "tar";
    const result = spawnSync(tar, ["-xf", file, "-C", out], { stdio: ["ignore", "ignore", "inherit"] });
    if (result.error || result.status !== 0) fail(`Could not unpack ${fromIndex >= 0 ? file : "the downloaded version"}.`);
    // GitHub's archives hold one folder with the whole project; this one is in typescript/ inside it.
    const candidates = [out, ...fs.readdirSync(out).map((name) => path.join(out, name))]
        .flatMap((dir) => [dir, path.join(dir, folderInRepo)]);
    const found = candidates.find((dir) => isFile(path.join(dir, "scripts", "update.mjs")) && isFile(path.join(dir, "package.json")));
    if (!found) fail(`${name} doesn't contain this project.`);
    return found;
}

// Copies the new version's files over this folder and removes the ones it no longer has.
function install(newDir) {
    const installed = readInstalled()?.files ?? {};
    const changes = { count: 0, keptEdits: [], replacedEdits: [] };
    let backupStarted = false;
    const backUp = (rel) => {
        if (!backupStarted) {
            fs.rmSync(backupDir, { recursive: true, force: true });
            backupStarted = true;
        }
        copy(path.join(projectDir, rel), path.join(backupDir, rel));
    };

    const newFiles = listProjectFiles(newDir);
    for (const rel of newFiles) {
        const local = path.join(projectDir, rel);
        const incoming = path.join(newDir, rel);
        if (isFile(local)) {
            const localHash = hashFile(local);
            if (localHash === hashFile(incoming)) continue;
            backUp(rel);
            // Changed since setup or the last update, so by you (or by setup, for package*.json).
            const edited = rel in installed && installed[rel] !== localHash;
            if (edited && rel.startsWith("examples/")) {
                fs.mkdirSync(myScriptsDir, { recursive: true });
                const name = freeName(myScriptsDir, path.basename(rel));
                copy(local, path.join(myScriptsDir, name));
                changes.keptEdits.push({ rel, name });
            } else if (edited && !rel.startsWith("package")) {
                changes.replacedEdits.push(rel);
            }
        }
        copy(incoming, local);
        changes.count++;
    }

    const stillThere = new Set(newFiles);
    for (const rel of Object.keys(installed)) {
        const local = path.join(projectDir, rel);
        if (stillThere.has(rel) || !isFile(local)) continue;
        backUp(rel);
        fs.rmSync(local);
        changes.count++;
    }
    return changes;
}

function copy(from, to) {
    fs.mkdirSync(path.dirname(to), { recursive: true });
    fs.copyFileSync(from, to);
}

function report({ count, keptEdits, replacedEdits }) {
    if (count === 0) {
        console.log(`Already up to date (${version}).`);
        return;
    }
    console.log(`\n${count} file(s) updated. The previous versions are saved in previous-version/.`);
    for (const { rel, name } of keptEdits) {
        const script = path.basename(name, path.extname(name));
        console.log(`\nYou had changed ${rel}. Your version is now my-scripts/${name}`);
        console.log(`(run it with: cvdesk ${script}), and ${rel} is the new version.`);
    }
    if (replacedEdits.length > 0) {
        console.log("\nYou had changed these project files. They were replaced; your versions are in previous-version/:");
        for (const rel of replacedEdits) console.log(`  ${rel}`);
    }
}
