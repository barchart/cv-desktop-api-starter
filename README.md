# cv-desktop-api-starter

Starter scripts for Barchart's cmdtyView Desktop API real-time market data, in
TypeScript, Python, Java, Go and C#. Setting up the Desktop API app itself is a
separate step: see the [official docs](https://docs.barchart.com/cmdtyview-docs/desktop-api/getting-started/).

## Getting started
1. **Run the setup** in this folder (how: see below). It asks which language you
   want, checks that it's installed (with a download link if not), installs what
   the scripts need, and installs the `cvdesk` command.

   | Language | Folder | Needs |
   |----------|--------|-------|
   | [TypeScript](typescript/README.md) | `typescript/` | Node.js 22+ |
   | [Python](python/README.md) | `python/` | Python 3.11+ (setup can install it) |
   | [Java](java/README.md) | `java/` | JDK 17+ |
   | [Go](go/README.md) | `go/` | Go 1.21+ |
   | [C#](csharp/README.md) | `csharp/` | .NET SDK 10+ |
2. **Open a new terminal window**, so it knows the `cvdesk` command.
3. **Add your credentials:** copy the starter guide from the language folder's
   `examples/` into its `my-scripts/`, and replace `YOUR_USERNAME` /
   `YOUR_PASSWORD` in the copy. Don't commit real credentials to git.
4. **Run it**, from any folder: `cvdesk start_guide.py` (or `start-guide.ts`,
   `StartGuide.java`, `start-guide.go`, `start-guide.cs`).

**Running the setup.** Open Terminal (macOS: `Cmd+Space`, type Terminal) or
PowerShell (Windows: Windows key, type PowerShell). Type `cd ` (with a space),
drag this project's folder onto the window, press Enter, then run:
```bash
./setup.command    # macOS (more reliable than double-clicking it)
.\setup.bat        # Windows
```
Pick one language or several (`1 2`). Each language folder also has its own
`setup.command` / `setup.bat` that sets up just that one. Running a setup again
is always safe.

## The `cvdesk` command
```bash
cvdesk start-guide.ts       # runs a script; the extension picks the language
cvdesk history.ts AAPL      # anything after the script goes to the script
cvdesk ~/Desktop/test.py    # a script anywhere: give its path
cvdesk                      # lists every language's scripts
cvdesk update               # installs the newest version of everything
cvdesk update python        # ...of one language folder
```
- Your own scripts go in a language's `my-scripts/` folder; updates never touch it.
  `cvdesk` looks there first, then in `examples/`.
- Names ignore case, `-` and `_`. Without an extension (`cvdesk history`), a name
  works if only one language you set up has it.
- If you move this folder or have several copies, `cvdesk` runs the copy you last
  ran a setup in. It replaces the `cvdesk-py` command of earlier versions.

## Updating
`cvdesk update` (or `./update.command` / `.\update.bat` in this folder) downloads
the latest GitHub release and installs it (TypeScript and Python only if you ran
their setup). It never touches `my-scripts/`, `.env` or installed packages. Every file it replaces is saved in `previous-version/`;
in TypeScript and Python, an example you had changed is moved into `my-scripts/`.
To install a zip you downloaded yourself: `cvdesk update --from <file.zip>`.

## Tips
- To read these `.md` files formatted: in VS Code press `Cmd+Shift+V` (macOS) or
  `Ctrl+Shift+V` (Windows); GitHub shows them formatted too.
- Changing how setup or updates work? Read [MAINTAINING.md](MAINTAINING.md) first.
