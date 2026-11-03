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

This checks your setup, runs `npm install`, and installs the `cvdesk` command,
which runs any script in `src/` from any folder (see below). It adds this
project's `bin/` folder to your PATH: in `~/.zshrc` on macOS, in your user
environment variables on Windows. `cvdesk` uses whichever Node.js version is
active, so switching versions with fnm or nvm doesn't affect it. Open a new
terminal window afterwards to use it. If you move this folder, run setup again.

## Add your credentials
Open [src/start-guide.ts](src/start-guide.ts) and replace `YOUR_USERNAME` / `YOUR_PASSWORD`
(`username` and `password` - search the file for `YOUR_USERNAME`) with your cmdtyView Desktop API credentials.
Do the same in any new script you add.

## Run it
From any folder:
```bash
cvdesk start-guide
```
or, from inside this `typescript` folder, `npm start`.

## Your own scripts
Put any number of `.ts` files in `src/` and run each one from any folder,
with optional arguments:
```bash
cvdesk my-script arg1 arg2
cvdesk                # lists the scripts in src/
```
New scripts work straight away; there's no need to re-run setup. From inside
this folder, `npm run file my-script` does the same without the global command.

`cvdesk` also runs `.ts` files anywhere else on your computer: give it the
file's path instead of a name.
```bash
cvdesk ./my-script.ts            # relative to the folder you're in
cvdesk ~/Desktop/test.ts arg1    # or a full path
```
Those scripts can import the same packages as the scripts in `src/` (for
example `@barchart/desktop-sdk-js`) without their own `npm install`, and get
the same type check and settings.

`cvdesk` type-checks that script (and anything it imports) first, and only runs it
if there are no type errors. Errors in other files in `src/` do not block it.
For quick iteration without the check, `npx tsx watch src/my-script.ts`
re-runs the script on every save (`npm run typecheck` checks types on demand).

The project runs as ES modules, so use `import` (not `require`), and you can
use `await` at the top level of a script.

## Troubleshooting
- "Invalid credentials" or login rejected -> check the username and password
  you entered in `src/start-guide.ts`.
- Re-running the setup script is safe.
