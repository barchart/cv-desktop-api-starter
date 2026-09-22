# Node.js Starter - Quick Notes

## Prerequisite
Node.js (LTS). Unlike Python, macOS ships with no Node.js at all, so
`setup.command`/`setup.bat` will always correctly detect if it's missing.

## First-time setup
- macOS: double-click `setup.command`
- Windows: double-click `setup.bat`

This asks for your OpenFeed credentials (saved to `.env` at the repo root) and
runs `npm install`.

## Run it
```bash
npm start
```

## Troubleshooting
- "Missing OPENFEED_USERNAME or OPENFEED_PASSWORD" -> check `.env` at the repo
  root has both values filled in.
- Re-running `setup.command` is safe - it skips credential setup if `.env`
  already exists.
