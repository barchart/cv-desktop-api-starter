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
