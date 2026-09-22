# Java Starter - Quick Notes

## Prerequisite
JDK 17+. No Maven install needed - the included `mvnw`/`mvnw.cmd` wrapper
downloads the right Maven version automatically.

## First-time setup
- macOS: double-click `setup.command`
- Windows: double-click `setup.bat`

This asks for your OpenFeed credentials (saved to `.env` at the repo root) and
builds a runnable jar via `mvnw package`.

## Run it
```bash
java -jar target/openfeed-client-1.0.0-jar-with-dependencies.jar
```

## Troubleshooting
- "Missing OPENFEED_USERNAME or OPENFEED_PASSWORD" -> check `.env` at the repo
  root has both values filled in.
- Re-running `setup.command` is safe - it skips credential setup if `.env`
  already exists.
