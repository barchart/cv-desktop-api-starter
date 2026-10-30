# TypeScript Starter - Quick Notes

## Source code
The actual program is [src/start-guide.ts](src/start-guide.ts). Open it in any
text editor or VS Code, change something, save, then re-run it with `npm start`
(see below) to see your change take effect.

## Prerequisite
Node.js 22 or newer (LTS). Unlike Python, macOS ships with no Node.js at
all, so `setup.command`/`setup.bat` will always correctly detect if it's
missing or too old.

If you work with several Node.js versions, a version manager makes switching
easy: [fnm](https://github.com/Schniz/fnm) (macOS/Windows),
[nvm](https://github.com/nvm-sh/nvm) (macOS) or
[nvm-windows](https://github.com/coreybutler/nvm-windows) (Windows).
Install the LTS version with `fnm install --lts`, `nvm install --lts`, or
`nvm install lts` (nvm-windows).

## First-time setup
- **macOS**: open Terminal, `cd` into this `typescript` folder (see the root
  [README](../README.md#getting-started-no-programming-experience-needed) if
  you're not sure how), then run:
  ```bash
  ./setup.command
  ```
- **Windows**: open PowerShell, `cd` into this `typescript` folder (see the root
  [README](../README.md#getting-started-no-programming-experience-needed) if
  you're not sure how), then run:
  ```powershell
  .\setup.bat
  ```

This asks for your cmdtyView Desktop API credentials (saved to `.env` in this folder and at
the repo root) and runs `npm install`.

## Run it
```bash
npm start
```

## Your own scripts
Put any number of `.ts` files in `src/` and run each one directly:
```bash
npx tsx src/my-script.ts
npx tsx watch src/my-script.ts   # re-runs automatically on save
```
`tsx` runs TypeScript without a build step but doesn't check types; run
`npm run typecheck` for that.

The project runs as ES modules, so use `import` (not `require`), and you can
use `await` at the top level of a script.

## Troubleshooting
- "Missing OPENFEED_USERNAME or OPENFEED_PASSWORD" -> check `.env` in this
  folder has both values filled in.
- Re-running `setup.command` is safe - it'll ask whether to set fresh
  credentials, or you can just edit `.env` in this folder by hand.
