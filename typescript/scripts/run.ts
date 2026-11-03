// Type-checks a single script (plus whatever it imports) using tsconfig.json,
// then runs it with tsx. Usage: npm run file src/my-script.ts
// Works from any directory, so the <name>-run commands on PATH can use it too.
import { spawnSync } from "node:child_process";
import { createRequire } from "node:module";
import path from "node:path";
import { fileURLToPath } from "node:url";
import ts from "typescript";

const projectDir = path.dirname(path.dirname(fileURLToPath(import.meta.url)));

const [fileArg, ...args] = process.argv.slice(2);
if (!fileArg) {
    console.error("Usage: npm run file src/my-script.ts");
    process.exit(1);
}
const file = path.resolve(fileArg);

const configPath = ts.findConfigFile(projectDir, ts.sys.fileExists)!;
const { config } = ts.readConfigFile(configPath, ts.sys.readFile);
const { options } = ts.parseJsonConfigFileContent(config, ts.sys, projectDir);

// Resolve @types and error paths from the project, not from wherever the command was run.
const host = ts.createCompilerHost(options);
host.getCurrentDirectory = () => projectDir;
const program = ts.createProgram([file], options, host);
const diagnostics = ts.getPreEmitDiagnostics(program);
if (diagnostics.length > 0) {
    console.error(ts.formatDiagnosticsWithColorAndContext(diagnostics, {
        getCanonicalFileName: (f) => f,
        getCurrentDirectory: () => projectDir,
        getNewLine: () => ts.sys.newLine,
    }));
    process.exit(1);
}

const tsxCli = createRequire(import.meta.url).resolve("tsx/cli");
const result = spawnSync(process.execPath, [tsxCli, file, ...args], { stdio: "inherit" });
process.exit(result.status ?? 1);
