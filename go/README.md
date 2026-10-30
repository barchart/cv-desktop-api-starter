# Go Starter - Quick Notes

## Source code
The actual program is [cmd/start-guide/main.go](cmd/start-guide/main.go). Open
it in any text editor or VS Code, change something, save, then re-run it with
`go run ./cmd/start-guide` (see below) to see your change take effect.

## Prerequisite
Go 1.21+.

## First-time setup
- **macOS**: open Terminal, `cd` into this `go` folder (see the root
  [README](../README.md#getting-started-no-programming-experience-needed) if
  you're not sure how), then run:
  ```bash
  ./setup.command
  ```
- **Windows**: double-click `setup.bat`

This asks for your cmdtyView Desktop API credentials (saved to `.env` in this folder and at
the repo root) and runs `go mod download`.

## Run it
```bash
go run ./cmd/start-guide
```

## Troubleshooting
- "Missing OPENFEED_USERNAME or OPENFEED_PASSWORD" -> check `.env` in this
  folder has both values filled in.
- Re-running `setup.command` is safe - it'll ask whether to set fresh
  credentials, or you can just edit `.env` in this folder by hand.
