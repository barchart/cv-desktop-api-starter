// Node.js module hooks that let scripts outside this project run like the ones
// in src/. Loaded by run.ts.
// - Packages a script imports (e.g. @barchart/desktop-sdk-js) are looked up
//   next to the script first, then in this project's node_modules.
// - .ts files outside the project run as ES modules (import, top-level await),
//   as they do inside it thanks to "type": "module" in package.json.
const projectUrl = new URL("../", import.meta.url).href;
const isBareSpecifier = (s) => !/^(\.|\/|[a-z]+:)/i.test(s);

export async function resolve(specifier, context, nextResolve) {
    let result;
    try {
        result = await nextResolve(specifier, context);
    } catch (error) {
        if (error?.code !== "ERR_MODULE_NOT_FOUND" || !isBareSpecifier(specifier)) throw error;
        result = await nextResolve(specifier, { ...context, parentURL: `${projectUrl}package.json` });
    }
    if (result.url.endsWith(".ts") && !result.url.startsWith(projectUrl)) {
        return { ...result, format: "module" };
    }
    return result;
}
