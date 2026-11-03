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

## Troubleshooting
- "Invalid credentials" or login rejected -> check the username and password
  you entered in `src/main/java/com/barchart/openfeed/StartGuide.java`.
- Re-running the setup script is safe.
