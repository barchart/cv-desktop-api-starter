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

This checks your setup, runs `npm install`, and creates a `<name>-run` command
for every script in `src/` (for example `start-guide-run`, `desktop-sdk-run`).
On macOS it adds the `bin/` folder with those commands to your PATH in
`~/.zshrc`. On Windows it installs them into npm's global folder (already on
your PATH), the same way `npm install -g` installs any tool; remove them with
`npm uninstall -g cv-desktop-api-starter-commands`. Open a new terminal window
afterwards to use them.

## Add your credentials
Open [src/start-guide.ts](src/start-guide.ts) and replace `YOUR_USERNAME` / `YOUR_PASSWORD`
(`username` and `password` - search the file for `YOUR_USERNAME`) with your cmdtyView Desktop API credentials.
Do the same in any new script you add.

## Run it
From any folder:
```bash
start-guide-run
```
or, from inside this `typescript` folder, `npm start`.

## Your own scripts
Put any number of `.ts` files in `src/`. To get a command for a new script,
re-run setup, or run this from inside the `typescript` folder:
```bash
npm run install-commands
```
Then `src/my-script.ts` runs from any folder as:
```bash
my-script-run arg1 arg2
```
Without installing a command, run it from inside this folder with
`npm run file src/my-script.ts`.

Both type-check that script (and anything it imports) first, and only run it
if there are no type errors. Errors in other files in `src/` do not block it.
For quick iteration without the check, `npx tsx watch src/my-script.ts`
re-runs the script on every save (`npm run typecheck` checks types on demand).

The project runs as ES modules, so use `import` (not `require`), and you can
use `await` at the top level of a script.

## Troubleshooting
- "Invalid credentials" or login rejected -> check the username and password
  you entered in `src/start-guide.ts`.
- Re-running the setup script is safe.
