# Go Starter - Quick Notes

## Prerequisite
Go 1.21+.

## First-time setup
- macOS: double-click `setup.command`
- Windows: double-click `setup.bat`

This asks for your OpenFeed credentials (saved to `.env` at the repo root) and
runs `go mod download`.

## Run it
```bash
go run ./cmd/start-guide
```

## Troubleshooting
- "Missing OPENFEED_USERNAME or OPENFEED_PASSWORD" -> check `.env` at the repo
  root has both values filled in.
- Re-running `setup.command` is safe - it skips credential setup if `.env`
  already exists.
