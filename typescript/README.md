# TypeScript Starter - Quick Notes

## Where things are
- [examples/](examples/) - example scripts that come with the project, such as
  [examples/start-guide.ts](examples/start-guide.ts). `cvdesk update` replaces them
  with their newest versions.
- `my-scripts/` - **your own scripts go here.** Setup creates it, and updates never
  touch it.

To change an example, copy it into `my-scripts/` first and change the copy.
`cvdesk start-guide` then runs your copy, because `my-scripts/` comes first.
If you change an example in place anyway, `cvdesk update` moves your version
into `my-scripts/` before it installs the new one, so nothing is lost.

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
which runs any script in `my-scripts/` or `examples/` from any folder (see below). It adds this
project's `bin/` folder to your PATH: in `~/.zshrc` on macOS, in your user
environment variables on Windows. `cvdesk` uses whichever Node.js version is
active, so switching versions with fnm or nvm doesn't affect it. Open a new
terminal window afterwards to use it. If you move this folder, run setup again.

## Add your credentials
Copy [examples/start-guide.ts](examples/start-guide.ts) into `my-scripts/`, open the
copy and replace `YOUR_USERNAME` / `YOUR_PASSWORD` (`username` and `password` -
search the file for `YOUR_USERNAME`) with your cmdtyView Desktop API credentials.
Do the same in any new script you add.

## Run it
From any folder:
```bash
cvdesk start-guide
```
or, from inside this `typescript` folder, `npm start`.

## Your own scripts
Put any number of `.ts` files in `my-scripts/` and run each one from any folder,
with optional arguments. Plain JavaScript files (`.js`, `.mjs`) work too:
```bash
cvdesk my-script arg1 arg2
cvdesk                # lists the scripts in my-scripts/ and examples/
```
New scripts work straight away; there's no need to re-run setup. From inside
this folder, `npm run file my-script` does the same without the global command.

`cvdesk` also runs `.ts` files anywhere else on your computer: give it the
file's path instead of a name.
```bash
cvdesk ./my-script.ts            # relative to the folder you're in
cvdesk ~/Desktop/test.ts arg1    # or a full path
```
Those scripts can import the same packages as the scripts in `my-scripts/` (for
example `@barchart/desktop-sdk-js`) without their own `npm install`, and get
the same type check and settings.

`cvdesk` type-checks that script (and anything it imports) first, and only runs it
if there are no type errors. Errors in other scripts do not block it.
JavaScript scripts are only checked for syntax errors and missing imports, not
types. If `my-script.ts` and `my-script.js` are both there, `cvdesk my-script`
runs the `.ts` one; give the path to run the other.
For quick iteration without the check, `npx tsx watch my-scripts/my-script.ts`
re-runs the script on every save (`npm run typecheck` checks types on demand).

The project runs as ES modules, so use `import` (not `require`), and you can
use `await` at the top level of a script.

## Getting the newest version
From any folder:
```bash
cvdesk update
```
This downloads the newest version of the project from GitHub (the latest
release, or the main branch if there are no releases), installs it, and
reinstalls dependencies if needed. It never touches `my-scripts/` or `.env`.
Every file it replaces or removes is saved in `previous-version/` first.

If you downloaded the project as a zip yourself (GitHub's **Code -> Download ZIP**),
install it with:
```bash
cvdesk update --from ~/Downloads/cv-desktop-api-starter-main.zip
```

Since `update` is the command's own name, a script called `update.ts` can only be
run by its path: `cvdesk ./my-scripts/update.ts`.

## Coming from an older version (scripts in `src/`)
Older versions kept everyone's scripts in `src/`, and they don't have `cvdesk update`.
Download the new version once more, unzip it **over your existing folder**, and run
the setup script again. Setup moves your scripts from `src/` into `my-scripts/`.
From then on, `cvdesk update` does the rest.

## Troubleshooting
- "Invalid credentials" or login rejected -> check the username and password
  you entered in `my-scripts/start-guide.ts`.
- Re-running the setup script is safe.
