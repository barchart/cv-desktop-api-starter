# cv-desktop-api-starter

Starter examples for connecting to Barchart's OpenFeed real-time market data service, available in Python, Node.js, Java, Go, and C#.

## Getting started (no programming experience needed)

Pick the language folder your team uses, then double-click the setup script for your operating system:

| Language | macOS | Windows |
|----------|-------|---------|
| [Python](python/README.md)   | `python/setup.command`   | `python/setup.bat`   |
| [Node.js](node/README.md)  | `node/setup.command`     | `node/setup.bat`     |
| [Java](java/README.md)     | `java/setup.command`     | `java/setup.bat`     |
| [Go](go/README.md)       | `go/setup.command`       | `go/setup.bat`       |
| [C#](csharp/README.md)       | `csharp/setup.command`   | `csharp/setup.bat`   |

Each script will:
1. Check that the required runtime is installed, and print a download link if it's missing.
2. Ask for your OpenFeed username and password the first time, and save them to a `.env` file at the repo root (never committed to git).
3. Download/install the project's dependencies.
4. Print the exact command to run the starter guide.

> On macOS, if double-clicking a `.command` file opens it in a text editor instead of running it, right-click the file, choose **Open**, and confirm. You may also need to allow it once under **System Settings > Privacy & Security**.