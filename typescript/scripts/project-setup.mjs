// The setup steps shared by setup.command, setup.bat and `cvdesk update`:
// - creates my-scripts/, the folder for your own scripts, which updates never touch
// - moves scripts from src/ (where they lived in older versions) into my-scripts/
// - installs dependencies and the latest @barchart/desktop-sdk-js
// - records which files came with the project (see update.mjs), if not done yet
// Plain JavaScript run with node, so it works before npm install.
import { spawnSync } from "node:child_process";
import fs from "node:fs";
import path from "node:path";
import { projectDir, myScriptsDir, examplesDir, readInstalled, writeInstalled, hashProjectFiles, freeName } from "./project-files.mjs";

fs.mkdirSync(myScriptsDir, { recursive: true });
moveOldScripts();
installDependencies();
if (!readInstalled()) {
    writeInstalled({ version: "unknown", files: hashProjectFiles() });
}

// Older versions kept everyone's scripts in src/, next to the examples.
// Files identical to an example are dropped; everything else moves to my-scripts/.
function moveOldScripts() {
    const srcDir = path.join(projectDir, "src");
    if (!fs.existsSync(srcDir)) return;
    const moved = [];
    for (const name of fs.readdirSync(srcDir)) {
        if (name === ".DS_Store") continue;
        const from = path.join(srcDir, name);
        const example = path.join(examplesDir, name);
        if (sameFile(from, example)) {
            fs.rmSync(from);
            continue;
        }
        const target = freeName(myScriptsDir, name);
        fs.renameSync(from, path.join(myScriptsDir, target));
        moved.push(target);
    }
    fs.rmSync(srcDir, { recursive: true, force: true });
    if (moved.length > 0) {
        console.log("\nMoved your scripts from src/ to my-scripts/:");
        for (const name of moved) console.log(`  ${name}`);
    }
}

function sameFile(a, b) {
    const isFile = (p) => fs.statSync(p, { throwIfNoEntry: false })?.isFile() ?? false;
    return isFile(a) && isFile(b) && fs.readFileSync(a).equals(fs.readFileSync(b));
}

// npm is npm.cmd on Windows, which Node only runs through a shell.
function npm(args, output = "inherit") {
    return spawnSync("npm", args, { cwd: projectDir, shell: process.platform === "win32", encoding: "utf8", stdio: ["inherit", output, "inherit"] });
}

function installDependencies() {
    console.log("\nInstalling dependencies...");
    const install = npm(["install", "--no-fund", "--no-audit", "--loglevel=error"]);
    if (install.status !== 0) {
        console.error("npm install failed.");
        process.exit(1);
    }

    const sdk = "@barchart/desktop-sdk-js";
    console.log(`\nChecking for the latest ${sdk}...`);
    const current = JSON.parse(fs.readFileSync(path.join(projectDir, "node_modules", sdk, "package.json"), "utf8")).version;
    const latest = npm(["view", sdk, "version"], "pipe").stdout?.trim();
    if (!latest) {
        console.log(`Could not reach the npm registry, keeping version ${current}.`);
    } else if (latest === current) {
        console.log(`Up to date (${current}).`);
    } else {
        console.log(`Updating ${current} -> ${latest}...`);
        npm(["install", `${sdk}@latest`, "--no-fund", "--no-audit", "--loglevel=error"]);
    }
}
