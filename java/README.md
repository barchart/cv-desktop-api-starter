# Java Starter - Quick Notes

## Source code
The actual program is
[src/main/java/com/barchart/openfeed/StartGuide.java](src/main/java/com/barchart/openfeed/StartGuide.java).
Open it in any text editor or VS Code, change something, save, then re-run it
with `./mvnw -q compile exec:java` (see below) to see your change take effect.

## Prerequisite
JDK 17+. No Maven install needed - the included `mvnw`/`mvnw.cmd` wrapper
downloads the right Maven version automatically.

## First-time setup
- **macOS**: open Terminal, `cd` into this `java` folder (see the root
  [README](../README.md#getting-started-no-programming-experience-needed) if
  you're not sure how), then run:
  ```bash
  ./setup.command
  ```
- **Windows**: open PowerShell, `cd` into this `java` folder (see the root
  [README](../README.md#getting-started-no-programming-experience-needed) if
  you're not sure how), then run:
  ```powershell
  .\setup.bat
  ```

This checks your setup and compiles the project via `mvnw compile`.

## Add your credentials
Open [src/main/java/com/barchart/openfeed/StartGuide.java](src/main/java/com/barchart/openfeed/StartGuide.java) and replace `YOUR_USERNAME` / `YOUR_PASSWORD`
(the `setUserName` and `setPassword` values - search the file for `YOUR_USERNAME`) with your cmdtyView Desktop API credentials.
Do the same in any new script you add.

## Run it
```bash
./mvnw -q compile exec:java
```

## Getting the newest version
From inside this `java` folder:
```bash
./update.command        # macOS
.\update.bat            # Windows (PowerShell)
```
This downloads the newest version of the project from GitHub (the latest
release, or the main branch if there are no releases) and installs it over
this folder. It leaves build output, `.env` and files you added alone. Every
file it replaces or removes is saved in `previous-version/` first.

The update replaces the example code too, so if you added your credentials to
`src/main/java/com/barchart/openfeed/StartGuide.java`, copy them from the same file in `previous-version/`
afterwards. The update lists the files you had changed.

If you downloaded the project as a zip yourself (GitHub's **Code -> Download ZIP**),
install it with:
```bash
./update.command --from ~/Downloads/cv-desktop-api-starter-main.zip
```

## Troubleshooting
- "Invalid credentials" or login rejected -> check the username and password
  you entered in `src/main/java/com/barchart/openfeed/StartGuide.java`.
- Re-running the setup script is safe.
