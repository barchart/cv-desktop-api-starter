// Creates a <name>-run command for every src/<name>.ts, so e.g. `desktop-sdk-run`
// works from any folder. Each command type-checks its script before running it
// (see run.ts).
//   macOS:   shell wrappers in bin/, and bin/ is added to PATH in ~/.zshrc
//            (or ~/.bash_profile for bash).
//   Windows: bin/ becomes a tiny npm package installed with `npm install -g`, so
//            npm puts the commands in its global folder, which the Node.js
//            installer already added to PATH. Nothing else on the system changes.
// Called by setup.command / setup.bat; re-run it after adding a new script:
//   npm run install-commands
import { execSync } from "node:child_process";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { fileURLToPath } from "node:url";

const isWindows = process.platform === "win32";
const projectDir = path.dirname(path.dirname(fileURLToPath(import.meta.url)));
const srcDir = path.join(projectDir, "src");
const binDir = path.join(projectDir, "bin");
const tsxCli = path.join(projectDir, "node_modules", "tsx", "dist", "cli.mjs");
const runner = path.join(projectDir, "scripts", "run.ts");
const packageName = "cv-desktop-api-starter-commands";

const scripts = fs.readdirSync(srcDir)
    .filter((f) => f.endsWith(".ts") && !f.endsWith(".d.ts"))
    .map((f) => path.basename(f, ".ts"));

if (isWindows) {
    // Remove the previous install first so commands for deleted scripts disappear.
    // npm needs the old bin/package.json for that, so this runs before bin/ is cleared.
    if (fs.existsSync(path.join(binDir, "package.json"))) {
        execSync(`npm uninstall -g ${packageName} --loglevel=error`, { stdio: "inherit" });
    }
}

// Start from an empty bin/ so commands for deleted scripts disappear.
fs.rmSync(binDir, { recursive: true, force: true });
fs.mkdirSync(binDir);

if (isWindows) {
    const bin: Record<string, string> = {};
    for (const name of scripts) {
        const script = path.join(srcDir, `${name}.ts`);
        bin[`${name}-run`] = `${name}-run.mjs`;
        fs.writeFileSync(path.join(binDir, `${name}-run.mjs`), [
            "#!/usr/bin/env node",
            `import { spawnSync } from "node:child_process";`,
            `const args = [${[tsxCli, runner, script].map((p) => JSON.stringify(p)).join(", ")}, ...process.argv.slice(2)];`,
            `const result = spawnSync(process.execPath, args, { stdio: "inherit" });`,
            "process.exit(result.status ?? 1);",
            "",
        ].join("\n"));
    }
    fs.writeFileSync(path.join(binDir, "package.json"),
        JSON.stringify({ name: packageName, version: "1.0.0", private: true, type: "module", bin }, null, 2));
    execSync(`npm install -g "${binDir}" --no-fund --no-audit --loglevel=error`, { stdio: "inherit" });
} else {
    for (const name of scripts) {
        const script = path.join(srcDir, `${name}.ts`);
        fs.writeFileSync(path.join(binDir, `${name}-run`),
            `#!/bin/sh\nexec node "${tsxCli}" "${runner}" "${script}" "$@"\n`, { mode: 0o755 });
    }
    const profile = path.join(os.homedir(), path.basename(process.env.SHELL ?? "") === "bash" ? ".bash_profile" : ".zshrc");
    const line = `export PATH="${binDir}:$PATH"`;
    const current = fs.existsSync(profile) ? fs.readFileSync(profile, "utf8") : "";
    if (!current.includes(line)) {
        fs.appendFileSync(profile, `\n# cmdtyView Desktop API TypeScript starter commands\n${line}\n`);
        console.log(`Added ${binDir} to your PATH in ${profile}.`);
    }
}

console.log(`Created ${scripts.length} command(s):`);
for (const name of scripts) console.log(`  ${name}-run`);
console.log("Open a new terminal window to use the commands.");
