# C# Starter - Quick Notes

## Source code
The actual program is
[OpenFeedStartGuide/Program.cs](OpenFeedStartGuide/Program.cs). Open it in any
text editor or VS Code, change something, save, then re-run it with
`dotnet run --project OpenFeedStartGuide` (see below) to see your change take effect.

## Prerequisite
.NET SDK 8.0+.

## First-time setup
- **macOS**: open Terminal, `cd` into this `csharp` folder (see the root
  [README](../README.md#getting-started-no-programming-experience-needed) if
  you're not sure how), then run:
  ```bash
  ./setup.command
  ```
- **Windows**: double-click `setup.bat`

This asks for your OpenFeed credentials (saved to `.env` at the repo root - see
the root [README](../README.md#where-are-my-credentials) if you can't find it)
and runs `dotnet restore`.

## Run it
```bash
dotnet run --project OpenFeedStartGuide
```
(run from the `csharp` folder)

## Troubleshooting
- "Missing OPENFEED_USERNAME or OPENFEED_PASSWORD" -> check `.env` at the repo
  root has both values filled in.
- Re-running `setup.command` is safe - it skips credential setup if `.env`
  already exists.
