// Type-checks a single script (plus whatever it imports) using tsconfig.json,
// then runs it with tsx. The script is either a file path (relative to the
// current folder, or absolute) or the name of a script in src/: `my-script`,
// `my-script.ts`. Without one, it lists the scripts in src/. Works from any
// directory, so the cvdesk command uses it.
import { spawnSync } from "node:child_process";
import { createRequire } from "node:module";
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath, pathToFileURL } from "node:url";
import ts from "typescript";

const projectDir = path.dirname(path.dirname(fileURLToPath(import.meta.url)));
const srcDir = path.join(projectDir, "src");

const scripts = fs.readdirSync(srcDir)
    .filter((f) => f.endsWith(".ts") && !f.endsWith(".d.ts"))
    .map((f) => path.basename(f, ".ts"));

const isFile = (p: string) => fs.statSync(p, { throwIfNoEntry: false })?.isFile() ?? false;

const [scriptArg, ...args] = process.argv.slice(2);
let file: string | undefined;
if (scriptArg && isFile(path.resolve(scriptArg))) {
    file = path.resolve(scriptArg);
} else if (scriptArg && scripts.includes(path.basename(scriptArg, ".ts"))) {
    file = path.join(srcDir, `${path.basename(scriptArg, ".ts")}.ts`);
} else {
    if (scriptArg) console.error(`No file "${scriptArg}" here and no script by that name in ${srcDir}\n`);
    console.error("Usage: cvdesk <script name or file path> [arguments]\n\nScripts in src/:");
    for (const s of scripts) console.error(`  ${s}`);
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
const registerHooks = "data:text/javascript," + encodeURIComponent(`import { register } from "node:module"; register(${JSON.stringify(hooks)});`);
const result = spawnSync(process.execPath, [tsxCli, "--import", registerHooks, file, ...args], { stdio: "inherit" });
process.exit(result.status ?? 1);
