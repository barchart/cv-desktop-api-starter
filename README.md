# cv-desktop-api-starter

Starter examples for connecting to Barchart's OpenFeed real-time market data service, available in Python, Node.js, Java, Go, and C#.

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

Each language has its own folder in this project (`python/`, `node/`, `java/`,
`go/`, `csharp/`), and inside that folder is a setup script:

| Language | Folder | macOS script | Windows script |
|----------|--------|--------------|----------------|
| [Python](python/README.md)  | `python/`  | `setup.command` | `setup.bat` |
| [Node.js](node/README.md)   | `node/`    | `setup.command` | `setup.bat` |
| [Java](java/README.md)      | `java/`    | `setup.command` | `setup.bat` |
| [Go](go/README.md)          | `go/`      | `setup.command` | `setup.bat` |
| [C#](csharp/README.md)      | `csharp/`  | `setup.command` | `setup.bat` |

**Windows**: double-click the `setup.bat` file inside that folder.

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
2. Ask for your OpenFeed username and password the first time, and save them to a `.env` file at the repo root (never committed to git).
3. Download/install the project's dependencies.
4. Print the exact command to run the starter guide.

## Where are my credentials?

Your OpenFeed username/password are saved in a file named `.env` at the very
root of this project (the same level as this README, one folder above every
language folder). Since its name starts with a dot, it may not show up by default:
- **macOS Finder**: press `Cmd+Shift+.` to toggle hidden files on/off.
- **Windows File Explorer**: `.env` should already be visible (Windows only
  hides files explicitly marked "Hidden", not dotfiles) - if you still don't
  see it, open the **View** tab and check **Hidden items**.
- **In VS Code**: it shows up normally in the file list on the left.
