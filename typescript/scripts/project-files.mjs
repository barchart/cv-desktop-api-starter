// Which files in this folder belong to the project (replaced by `cvdesk update`)
// and which are yours (never touched). Used by project-setup.mjs and update.mjs.
import crypto from "node:crypto";
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

export const projectDir = path.dirname(path.dirname(fileURLToPath(import.meta.url)));
export const myScriptsDir = path.join(projectDir, "my-scripts");
export const examplesDir = path.join(projectDir, "examples");
export const backupDir = path.join(projectDir, "previous-version");
const installedFile = path.join(projectDir, ".cvdesk-installed.json");

// Never replaced or removed by an update. src/ is where older versions kept scripts.
const yours = new Set(["my-scripts", "node_modules", "previous-version", "src", ".env", ".cvdesk-installed.json"]);
const ignored = new Set([".DS_Store", "Thumbs.db"]);

// Every project file under dir, as paths relative to it with forward slashes.
export function listProjectFiles(dir) {
    const files = [];
    const walk = (rel) => {
        for (const entry of fs.readdirSync(path.join(dir, rel), { withFileTypes: true })) {
            if (ignored.has(entry.name) || (rel === "" && yours.has(entry.name))) continue;
            const child = rel ? `${rel}/${entry.name}` : entry.name;
            if (entry.isDirectory()) walk(child);
            else if (entry.isFile()) files.push(child);
        }
    };
    walk("");
    return files;
}

export const hashFile = (file) => crypto.createHash("sha256").update(fs.readFileSync(file)).digest("hex");

export function hashProjectFiles(dir = projectDir) {
    return Object.fromEntries(listProjectFiles(dir).map((rel) => [rel, hashFile(path.join(dir, rel))]));
}

// What the last setup or update installed: { version, files: { "path": sha256 } }.
export function readInstalled() {
    try {
        return JSON.parse(fs.readFileSync(installedFile, "utf8"));
    } catch {
        return undefined;
    }
}

export function writeInstalled(installed) {
    fs.writeFileSync(installedFile, JSON.stringify(installed, null, 2) + "\n");
}

// name if it's free in dir, otherwise name-2, name-3, ... (before the extension).
export function freeName(dir, name) {
    const ext = path.extname(name);
    const base = path.basename(name, ext);
    let candidate = name;
    for (let i = 2; fs.existsSync(path.join(dir, candidate)); i++) candidate = `${base}-${i}${ext}`;
    return candidate;
}
