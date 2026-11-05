// Type-checks a single script (plus whatever it imports) using tsconfig.json,
// then runs it with tsx. The script is either a file path (relative to the
// current folder, or absolute) or the name of a script in my-scripts/ or
// examples/: `my-script`, `my-script.ts`. my-scripts/ wins if both have one.
// Without one, it lists the scripts. Works from any directory, so the cvdesk
// command uses it.
import { spawnSync } from "node:child_process";
import { createRequire } from "node:module";
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath, pathToFileURL } from "node:url";
import ts from "typescript";

const projectDir = path.dirname(path.dirname(fileURLToPath(import.meta.url)));
const scriptDirs = ["my-scripts", "examples"];

const scriptsIn = (dir: string) => (fs.existsSync(path.join(projectDir, dir)) ? fs.readdirSync(path.join(projectDir, dir)) : [])
    .filter((f) => f.endsWith(".ts") && !f.endsWith(".d.ts"))
    .map((f) => path.basename(f, ".ts"));

const isFile = (p: string) => fs.statSync(p, { throwIfNoEntry: false })?.isFile() ?? false;

const [scriptArg, ...args] = process.argv.slice(2);
const scriptName = scriptArg && path.basename(scriptArg, ".ts");
const scriptDir = scriptName && scriptDirs.find((dir) => scriptsIn(dir).includes(scriptName));
let file: string | undefined;
if (scriptArg && isFile(path.resolve(scriptArg))) {
    file = path.resolve(scriptArg);
} else if (scriptDir) {
    file = path.join(projectDir, scriptDir, `${scriptName}.ts`);
} else {
    if (scriptArg) console.error(`No file "${scriptArg}" here and no script by that name in ${scriptDirs.join("/ or ")}/\n`);
    console.error("Usage: cvdesk <script name or file path> [arguments]");
    console.error("       cvdesk update     (installs the newest version of this project)");
    for (const dir of scriptDirs) {
        console.error(`\nScripts in ${dir}/:`);
        const scripts = scriptsIn(dir);
        if (scripts.length === 0) console.error("  (none yet)");
        for (const s of scripts) console.error(`  ${s}`);
    }
    process.exit(1);
}
const insideProject = !path.relative(projectDir, file).startsWith("..");

const configPath = ts.findConfigFile(projectDir, ts.sys.fileExists)!;
const { config } = ts.readConfigFile(configPath, ts.sys.readFile);
const { options } = ts.parseJsonConfigFileContent(config, ts.sys, projectDir);

// Resolve @types and error paths from the project, not from wherever the command was run.
const host = ts.createCompilerHost(options);
host.getCurrentDirectory = () => projectDir;
// Packages a script outside the project imports are looked up in the project
// too, as project-imports.mjs does at run time.
const projectFile = path.join(projectDir, "package.json");
host.resolveModuleNameLiterals = (literals, containingFile, _redirected, opts) => literals.map(({ text }) => {
    const resolved = ts.resolveModuleName(text, containingFile, opts, host);
    return resolved.resolvedModule ? resolved : ts.resolveModuleName(text, projectFile, opts, host);
});
const program = ts.createProgram([file], options, host);
const diagnostics = ts.getPreEmitDiagnostics(program);
if (diagnostics.length > 0) {
    console.error(ts.formatDiagnosticsWithColorAndContext(diagnostics, {
        getCanonicalFileName: (f) => f,
        getCurrentDirectory: () => insideProject ? projectDir : process.cwd(),
        getNewLine: () => ts.sys.newLine,
    }));
    process.exit(1);
}

const tsxCli = createRequire(import.meta.url).resolve("tsx/cli");
const hooks = pathToFileURL(path.join(projectDir, "scripts", "project-imports.mjs")).href;
const registerHooks = "data:text/javascript," + encodeURIComponent(`import * as m from "node:module";
if (m.registerHooks) m.registerHooks({ resolve: (await import(${JSON.stringify(hooks)})).resolveSync });
else m.register(${JSON.stringify(hooks)});`);
const result = spawnSync(process.execPath, [tsxCli, "--import", registerHooks, file, ...args], { stdio: "inherit" });
process.exit(result.status ?? 1);
