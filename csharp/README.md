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

## Troubleshooting
- "Invalid credentials" or login rejected -> check the username and password
  you entered in `OpenFeedStartGuide/Program.cs`.
- Re-running the setup script is safe.
