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
- **Windows**: double-click `setup.bat`

This asks for your OpenFeed credentials (saved to `.env` in this folder and at
the repo root) and compiles the project via `mvnw compile`.

## Run it
```bash
./mvnw -q compile exec:java
```

## Troubleshooting
- "Missing OPENFEED_USERNAME or OPENFEED_PASSWORD" -> check `.env` in this
  folder has both values filled in.
- Re-running `setup.command` is safe - it'll ask whether to set fresh
  credentials, or you can just edit `.env` in this folder by hand.
