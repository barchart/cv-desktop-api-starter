# cv-desktop-api-starter

Starter examples for connecting to Barchart's cmdtyView Desktop API real-time market data service, available in Python, Node.js, Java, Go, and C#.

Setting up the Barchart Desktop API app itself is a separate step, done in parallel with this starter kit - see the official docs: https://docs.barchart.com/cmdtyview-docs/desktop-api/getting-started/

## New to reading `.md` files?

This README (and the ones inside each language folder) are Markdown files -
that's why you see symbols like `#` and `**` in the raw text. To read them
nicely formatted instead of as plain text:
- **In VS Code**: click the file in the left-hand file list, then press
  `Cmd+Shift+V` (macOS) or `Ctrl+Shift+V` (Windows) to open a formatted preview.
- **On GitHub**: open the file in your browser - GitHub renders Markdown automatically.
- Opening it in Notepad/TextEdit works too, it'll just show the raw `#`/`**` symbols.

## Getting started (no programming experience needed)

Each language has its own folder in this project (`python/`, `typescript/`, `java/`,
`go/`, `csharp/`), and inside that folder is a setup script:

| Language | Folder | macOS script | Windows script |
|----------|--------|--------------|----------------|
| [Python](python/README.md)  | `python/`  | `setup.command` | `setup.bat` |
| [TypeScript](typescript/README.md) | `typescript/` | `setup.command` | `setup.bat` |
| [Java](java/README.md)      | `java/`    | `setup.command` | `setup.bat` |
| [Go](go/README.md)          | `go/`      | `setup.command` | `setup.bat` |
| [C#](csharp/README.md)      | `csharp/`  | `setup.command` | `setup.bat` |

**Windows**: run the script from PowerShell. Steps:
1. Open **PowerShell** (press the Windows key, type `PowerShell`, press Enter).
2. Move into the language folder. Type `cd ` (with a trailing space), then
   drag that folder from File Explorer straight onto the PowerShell window -
   it fills in the full path for you - then press Enter.
3. Run the script:
   ```powershell
   .\setup.bat
   ```

**macOS**: run the script from Terminal rather than double-clicking it -
double-clicking often gets blocked by macOS's Gatekeeper security ("cannot be
opened because it is from an unidentified developer"), while running it from
Terminal avoids that entirely. Steps:
1. Open **Terminal** (press `Cmd+Space`, type `Terminal`, press Enter).
2. Move into the language folder. Type `cd ` (with a trailing space), then
   drag that folder from Finder straight onto the Terminal window - it fills
   in the full path for you - then press Enter.
3. Run the script:
   ```bash
   ./setup.command
   ```

Each script will:
1. Check that the required runtime is installed, and print a download link if it's missing.
2. Download/install the project's dependencies.
3. Print the exact command to run the starter guide.

Before running, open the starter script and replace the `YOUR_USERNAME` /
`YOUR_PASSWORD` placeholders with your cmdtyView Desktop API
credentials - each language's README shows which file. Don't commit your real
credentials to git.

## Getting the newest version

To update every language folder at once, run this from the top folder of the project
(the one with this README):
```bash
./update.command   # macOS
.\update.bat       # Windows
```
It downloads the newest version once and updates each folder the same way that folder's
own update does (see below). TypeScript and Python are only updated if you ran their setup,
since their update also updates their dependencies; Java, Go and C# are always updated.
At the end it lists which folders it updated or skipped.

Or update just one language folder:

| Language | Update (from any folder) | Update (from inside the language folder) |
|----------|--------------------------|------------------------------------------|
| [TypeScript](typescript/README.md#getting-the-newest-version) | `cvdesk update` | |
| [Python](python/README.md#getting-the-newest-version) | `cvdesk-py update` | |
| [Java](java/README.md#getting-the-newest-version) | | `./update.command` (macOS), `.\update.bat` (Windows) |
| [Go](go/README.md#getting-the-newest-version) | | `./update.command` (macOS), `.\update.bat` (Windows) |
| [C#](csharp/README.md#getting-the-newest-version) | | `./update.command` (macOS), `.\update.bat` (Windows) |

Each one updates only its own language folder, and they all work the same way:
- They install the latest GitHub release of this project, or the main branch if
  there are no releases. Adding `--from <zip>` installs a zip you downloaded yourself.
- `.env`, installed dependencies, build output and files you added are never touched.
  In TypeScript and Python, your own scripts go in `my-scripts/`, which updates never touch.
- The example code is replaced with its newest version. In TypeScript and Python,
  an example you changed is moved into `my-scripts/` first.
- Every file an update replaces or removes is saved in `previous-version/`.

### For maintainers: how updates stay working

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
- The top-level `update.command` / `update.bat` follow the same pattern: `scripts/update.sh`
  / `.ps1` downloads, then the downloaded `scripts/install-update.sh` / `.ps1` updates the
  top-level files and runs each language's install step. A new language folder only needs
  adding there.
- Updaters replace their own files while they run. Bash and `cmd` read a script while
  running it, so keep every `update.sh` inside its `{ ... exit }` block, and keep the
  last command of every `.bat` / `.cmd` on the same line as its `& exit /b`.
