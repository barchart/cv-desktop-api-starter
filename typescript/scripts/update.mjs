// `cvdesk update`: downloads the newest version of this project from GitHub and
// installs it over this folder, without touching your own files (my-scripts/,
// .env). It takes the latest GitHub release, or the main branch if the project
// has no releases.
// - Every file it replaces or removes is saved in previous-version/ first.
// - If you changed one of the examples, your version is moved to my-scripts/.
// `cvdesk update --from <file>` installs a .zip or .tar.gz of the project you
// downloaded yourself, for example from GitHub's "Download ZIP".
// This file only downloads. The installing is done by install-update.mjs from the
// version it downloads, so each new version brings its own install steps. Keep
// this file simple: copies of it already out there have to keep working with
// every future version.
// Plain JavaScript run with node (not tsx), since the install step may reinstall node_modules.
import { spawnSync } from "node:child_process";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { projectDir, readInstalled } from "./project-files.mjs";

const repo = "barchart/cv-desktop-api-starter";
const folderInRepo = "typescript";

const fail = (message) => {
    console.error(message);
    process.exit(1);
};
const isFile = (p) => fs.statSync(p, { throwIfNoEntry: false })?.isFile() ?? false;

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
// The new version's own install step (see install-update.mjs for the arguments).
const install = [path.join(newDir, "scripts", "install-update.mjs"), newDir, projectDir, version, ...(notes ? [notes] : [])];
const result = spawnSync(process.execPath, install, { stdio: "inherit" });
process.exitCode = result.status ?? 1;

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
    const found = candidates.find((dir) => isFile(path.join(dir, "scripts", "install-update.mjs")) && isFile(path.join(dir, "package.json")));
    if (!found) fail(`${name} doesn't contain this project.`);
    return found;
}
