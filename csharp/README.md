# C# Starter - Quick Notes

## Prerequisite
.NET SDK 10.0+.

## First-time setup
- macOS: double-click `setup.command`
- Windows: double-click `setup.bat`

This asks for your OpenFeed credentials (saved to `.env` at the repo root) and
runs `dotnet restore`.

## Run it
```bash
cd OpenFeedStartGuide
dotnet run
```

## Troubleshooting
- "Missing OPENFEED_USERNAME or OPENFEED_PASSWORD" -> check `.env` at the repo
  root has both values filled in.
- Re-running `setup.command` is safe - it skips credential setup if `.env`
  already exists.
