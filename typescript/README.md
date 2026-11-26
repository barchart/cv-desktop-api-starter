# TypeScript Starter

Setup, credentials, `cvdesk` and updating work the same in every language: see the
[main README](../README.md). This page covers what's specific to TypeScript.

## Needs
Node.js 22+ (LTS) from [nodejs.org](https://nodejs.org/), or via a version manager
such as [fnm](https://github.com/Schniz/fnm) or [nvm](https://github.com/nvm-sh/nvm).
`cvdesk` uses whichever Node.js version is active.

## Examples
In [examples/](examples/): [start-guide.ts](examples/start-guide.ts) (credentials:
`username` / `password`), [desktop-sdk.ts](examples/desktop-sdk.ts),
[history.ts](examples/history.ts).

## Writing scripts
- `.ts` files, or plain `.js` / `.mjs`. They run as ES modules: use `import`, and
  `await` works at the top level.
- `cvdesk` type-checks a script (and what it imports) before running it, and only
  runs it without type errors. `.js` files are only checked for syntax and imports.
- Scripts anywhere on your computer can import this project's packages (such as
  `@barchart/desktop-sdk-js`) without their own `npm install`.
- Quick iteration without the check: `npx tsx watch my-scripts/my-script.ts`
  (from this folder) re-runs on every save; `npm run typecheck` checks all types.

## Troubleshooting
- Login rejected -> check the credentials in `my-scripts/start-guide.ts`.
- `cvdesk: command not found` -> open a new terminal window, or run setup again.
- Coming from a version that kept scripts in `src/`? Unzip the new version over
  your folder and run setup again: it moves them into `my-scripts/`.
