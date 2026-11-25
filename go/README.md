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
- **Windows**: open PowerShell, `cd` into this `go` folder (see the root
  [README](../README.md#getting-started-no-programming-experience-needed) if
  you're not sure how), then run:
  ```powershell
  .\setup.bat
  ```

This checks your setup and runs `go mod download`.

## Add your credentials
Open [cmd/start-guide/main.go](cmd/start-guide/main.go) and replace `YOUR_USERNAME` / `YOUR_PASSWORD`
(`username` and `password` - search the file for `YOUR_USERNAME`) with your cmdtyView Desktop API credentials.
Do the same in any new script you add.

## Run it
```bash
go run ./cmd/start-guide
```

## Getting the newest version
From inside this `go` folder:
```bash
./update.command        # macOS
.\update.bat            # Windows (PowerShell)
```
This downloads the newest version of the project from GitHub (the latest
release, or the main branch if there are no releases) and installs it over
this folder. It leaves build output, `.env` and files you added alone. Every
file it replaces or removes is saved in `previous-version/` first.

The update replaces the example code too, so if you added your credentials to
`cmd/start-guide/main.go`, copy them from the same file in `previous-version/`
afterwards. The update lists the files you had changed.

If you downloaded the project as a zip yourself (GitHub's **Code -> Download ZIP**),
install it with:
```bash
./update.command --from ~/Downloads/cv-desktop-api-starter-main.zip
```

## Troubleshooting
- "Invalid credentials" or login rejected -> check the username and password
  you entered in `cmd/start-guide/main.go`.
- Re-running the setup script is safe.
