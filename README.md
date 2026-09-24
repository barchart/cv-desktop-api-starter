# cv-desktop-api-starter

Starter examples for connecting to Barchart's cmdtyView Dektop API real-time market data service, available in Python, Node.js, Java, Go, and C#.

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
2. Ask for your cmdtyView Dektop API username and password the first time, and save them to a `.env` file at the repo root and in that language folder (never committed to git).
3. Download/install the project's dependencies.
4. Print the exact command to run the starter guide.

To change your credentials later, either re-run that language's setup script
(it'll ask "Set fresh credentials?") or just edit that folder's `.env` by
hand - both are perfectly fine ways to update them.
