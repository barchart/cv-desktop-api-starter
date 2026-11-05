// Node.js module hooks that let scripts outside this project run like the ones
// in my-scripts/ and examples/. Loaded by run.ts.
// - Packages a script imports (e.g. @barchart/desktop-sdk-js) are looked up
//   next to the script first, then in this project's node_modules.
// - .ts files outside the project run as ES modules (import, top-level await),
//   as they do inside it thanks to "type": "module" in package.json.
// resolveSync is for module.registerHooks() (Node 22.15+); resolve is for the
// older module.register(), which is deprecated from Node 26.
const projectUrl = new URL("../", import.meta.url).href;
const isBareSpecifier = (s) => !/^(\.|\/|[a-z]+:)/i.test(s);
const isNotFound = (error, specifier) => error?.code === "ERR_MODULE_NOT_FOUND" && isBareSpecifier(specifier);
const fromProject = (context) => ({ ...context, parentURL: `${projectUrl}package.json` });

function withFormat(result) {
    if (result.url.endsWith(".ts") && !result.url.startsWith(projectUrl)) {
        return { ...result, format: "module" };
    }
    return result;
}

export function resolveSync(specifier, context, nextResolve) {
    try {
        return withFormat(nextResolve(specifier, context));
    } catch (error) {
        if (!isNotFound(error, specifier)) throw error;
        return withFormat(nextResolve(specifier, fromProject(context)));
    }
}

export async function resolve(specifier, context, nextResolve) {
    try {
        return withFormat(await nextResolve(specifier, context));
    } catch (error) {
        if (!isNotFound(error, specifier)) throw error;
        return withFormat(await nextResolve(specifier, fromProject(context)));
    }
}
