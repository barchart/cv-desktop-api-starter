// Installs a downloaded version of this project over your copy. update.mjs (the
// copy you already have) downloads the new version, then runs this script from
// inside the download - so this is the new version's install step.
//
//     node install-update.mjs <new version's folder> <your project folder> <version name> [<release notes>]
//
// These arguments are a contract: copies of update.mjs already out there call
// every future version of this script exactly like this.
//
// - Copies every file of the new version over your folder, without touching your
//   own files (my-scripts/, .env, node_modules/).
// - Every file it replaces or removes is saved in previous-version/ first.
// - If you changed one of the examples, your version is moved to my-scripts/.
// - Then runs the new version's project-setup.mjs (npm install, move old scripts out of src/).
// - Puts the cvdesk command for every language on PATH, if it isn't yet. A copy of
//   the project without it yet gets the whole project updated instead (see
//   handOverToWholeProject).
// Plain JavaScript run with node (not tsx), since it may reinstall node_modules.
import { spawnSync } from "node:child_process";
import fs from "node:fs";
import path from "node:path";
// The new version's project-files.mjs, next to this file.
import { listProjectFiles, hashFile, hashProjectFiles, readInstalled, writeInstalled, freeName } from "./project-files.mjs";

const [newDir, projectDir, version, notes] = [path.resolve(process.argv[2]), path.resolve(process.argv[3]), process.argv[4], process.argv[5]];
const myScriptsDir = path.join(projectDir, "my-scripts");
const backupDir = path.join(projectDir, "previous-version");

const fail = (message) => {
    console.error(message);
    process.exit(1);
};
const isFile = (p) => fs.statSync(p, { throwIfNoEntry: false })?.isFile() ?? false;
const isDir = (p) => fs.statSync(p, { throwIfNoEntry: false })?.isDirectory() ?? false;

const handedOver = handOverToWholeProject();
if (handedOver !== null) process.exit(handedOver);
const changes = install();
writeInstalled({ version, files: hashProjectFiles(newDir) }, projectDir);
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
putCvdeskOnPath();

// The cvdesk command for every language comes with the files at the top of the
// project (bin/). A copy that doesn't have those yet gets the whole project updated
// instead of only this folder, from the same download (GitHub's archives hold the
// whole project). Returns that update's exit code, or null to update only this folder.
function handOverToWholeProject() {
    const newRoot = path.dirname(newDir);
    const root = path.dirname(projectDir);
    if (isFile(path.join(root, "bin", "cvdesk")) || !isFile(path.join(newRoot, "bin", "cvdesk"))) return null;
    // Only inside a copy of the whole project, never wherever this folder was moved to.
    if (path.basename(projectDir) !== "typescript" || !["python", "java", "go", "csharp"].some((d) => isDir(path.join(root, d)))) return null;
    console.log("This version has cvdesk, one command for the scripts of every language, which comes");
    console.log("with the files at the top of the project. So this updates the whole project.");
    const install = process.platform === "win32"
        ? ["powershell.exe", ["-NoProfile", "-ExecutionPolicy", "Bypass", "-File", path.join(newRoot, "scripts", "install-update.ps1")]]
        : ["bash", [path.join(newRoot, "scripts", "install-update.sh")]];
    return spawnSync(install[0], [...install[1], newRoot, root, version], { stdio: "inherit" }).status ?? 1;
}

function putCvdeskOnPath() {
    const root = path.dirname(projectDir);
    if (!isFile(path.join(root, "bin", "cvdesk"))) return;
    const add = process.platform === "win32"
        ? ["powershell.exe", ["-NoProfile", "-ExecutionPolicy", "Bypass", "-File", path.join(root, "scripts", "add-to-path.ps1")]]
        : ["bash", [path.join(root, "scripts", "add-to-path.sh")]];
    spawnSync(add[0], [...add[1], "--if-needed"], { stdio: "inherit" });
}

// Copies the new version's files over the project and removes the ones it no longer has.
function install() {
    const installed = readInstalled(projectDir)?.files ?? {};
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
        console.log(`\nYou had changed ${rel}. Your version is now my-scripts/${name}`);
        console.log(`(run it with: cvdesk ${name}), and ${rel} is the new version.`);
    }
    if (replacedEdits.length > 0) {
        console.log("\nYou had changed these project files. They were replaced; your versions are in previous-version/:");
        for (const rel of replacedEdits) console.log(`  ${rel}`);
    }
}
