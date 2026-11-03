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

This checks your setup and runs `npm install`.

## Add your credentials
Open [src/start-guide.ts](src/start-guide.ts) and replace `YOUR_USERNAME` / `YOUR_PASSWORD`
(`username` and `password` - search the file for `YOUR_USERNAME`) with your cmdtyView Desktop API credentials.
Do the same in any new script you add.

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
- "Invalid credentials" or login rejected -> check the username and password
  you entered in `src/start-guide.ts`.
- Re-running the setup script is safe.
