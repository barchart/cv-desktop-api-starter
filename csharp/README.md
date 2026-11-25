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
- **Windows**: open PowerShell, `cd` into this `csharp` folder (see the root
  [README](../README.md#getting-started-no-programming-experience-needed) if
  you're not sure how), then run:
  ```powershell
  .\setup.bat
  ```

This checks your setup and runs `dotnet restore`.

## Add your credentials
Open [OpenFeedStartGuide/Program.cs](OpenFeedStartGuide/Program.cs) and replace `YOUR_USERNAME` / `YOUR_PASSWORD`
(`username` and `password` - search the file for `YOUR_USERNAME`) with your cmdtyView Desktop API credentials.
Do the same in any new script you add.

## Run it
```bash
dotnet run --project OpenFeedStartGuide
```
(run from the `csharp` folder)

## Getting the newest version
From inside this `csharp` folder:
```bash
./update.command        # macOS
.\update.bat            # Windows (PowerShell)
```
This downloads the newest version of the project from GitHub (the latest
release, or the main branch if there are no releases) and installs it over
this folder. It leaves build output, `.env` and files you added alone. Every
file it replaces or removes is saved in `previous-version/` first.

The update replaces the example code too, so if you added your credentials to
`OpenFeedStartGuide/Program.cs`, copy them from the same file in `previous-version/`
afterwards. The update lists the files you had changed.

If you downloaded the project as a zip yourself (GitHub's **Code -> Download ZIP**),
install it with:
```bash
./update.command --from ~/Downloads/cv-desktop-api-starter-main.zip
```

## Troubleshooting
- "Invalid credentials" or login rejected -> check the username and password
  you entered in `OpenFeedStartGuide/Program.cs`.
- Re-running the setup script is safe.
