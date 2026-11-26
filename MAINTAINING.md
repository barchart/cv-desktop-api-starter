# Maintaining this project

## How updates stay working

The updater in a user's copy only downloads the new version. It then runs the
install step **from the downloaded version** (`scripts/install-update.mjs`,
`scripts/install_update.py`, or `scripts/install-update.sh` / `.ps1`), so changes
to how a folder is installed reach users with the release that makes them. Two
rules keep this working:
- Never rename or remove the install step, and keep accepting its arguments
  (`<new folder> <project folder> <version name> [<notes or release URL>]`).
  Copies already out there call it exactly like that.
- Keep the downloading part (`update.mjs`, `update.py`, `update.sh` / `.ps1`)
  simple and stable. A change to it only reaches users after they have updated once.
- `bin/cvdesk` (macOS) and `scripts/cvdesk.ps1` (Windows, run by `bin/cvdesk.cmd`) are
  the same command written twice: change them together. Adding a language means adding
  it to both, to `scripts/install-update.sh` / `.ps1`, and having its setup run
  `scripts/add-to-path.sh` / `.ps1`.
- The top-level `update.command` / `update.bat` follow the same pattern: `scripts/update.sh`
  / `.ps1` downloads, then the downloaded `scripts/install-update.sh` / `.ps1` updates the
  top-level files and runs each language's install step. A new language folder only needs
  adding there.
- Updaters replace their own files while they run. Bash and `cmd` read a script while
  running it, so keep every `update.sh` inside its `{ ... exit }` block, and keep the
  last command of every `.bat` / `.cmd` on the same line as its `& exit /b`.

## Setup
The top-level `setup.command` / `setup.bat` asks which languages to set up and runs each
language's own setup with `CVDESK_SETUP_FROM_TOP=1` set. A language setup then skips its
final "Press Enter" pause (the top-level one pauses once at the end), and must exit 0 on
success and non-zero on failure. A new language needs adding to both menus.
