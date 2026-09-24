# Node.js Starter - Quick Notes

## Source code
The actual program is [src/start-guide.ts](src/start-guide.ts). Open it in any
text editor or VS Code, change something, save, then re-run it with `npm start`
(see below) to see your change take effect.

## Prerequisite
Node.js (LTS). Unlike Python, macOS ships with no Node.js at all, so
`setup.command`/`setup.bat` will always correctly detect if it's missing.

## First-time setup
- **macOS**: open Terminal, `cd` into this `node` folder (see the root
  [README](../README.md#getting-started-no-programming-experience-needed) if
  you're not sure how), then run:
  ```bash
  ./setup.command
  ```
- **Windows**: double-click `setup.bat`

This asks for your OpenFeed credentials (saved to `.env` at the repo root - see
the root [README](../README.md#where-are-my-credentials) if you can't find it)
and runs `npm install`.

## Run it
```bash
npm start
```

## Troubleshooting
- "Missing OPENFEED_USERNAME or OPENFEED_PASSWORD" -> check `.env` at the repo
  root has both values filled in.
- Re-running `setup.command` is safe - it skips credential setup if `.env`
  already exists.
