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

This asks for your cmdtyView Dektop API credentials (saved to `.env` in this folder and at
the repo root) and runs `dotnet restore`.

## Run it
```bash
dotnet run --project OpenFeedStartGuide
```
(run from the `csharp` folder)

## Troubleshooting
- "Missing OPENFEED_USERNAME or OPENFEED_PASSWORD" -> check `.env` in this
  folder has both values filled in.
- Re-running `setup.command` is safe - it'll ask whether to set fresh
  credentials, or you can just edit `.env` in this folder by hand.
