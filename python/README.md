# Python Starter - Quick Notes

## Prerequisite
Python 3.9+. On macOS, `python3` may exist as a placeholder even without Xcode
Command Line Tools installed - if `setup.command` errors out, accept the
"Install Command Line Developer Tools" popup if you see one, then re-run it.

## First-time setup
- macOS: double-click `setup.command`
- Windows: double-click `setup.bat`

This asks for your OpenFeed credentials (saved to `.env` at the repo root) and
creates a `venv` folder with dependencies installed.

## Run it
```bash
source venv/bin/activate   # macOS/Linux
venv\Scripts\activate.bat  # Windows

python3 src/start_guide.py
```

## Troubleshooting
- "Missing OPENFEED_USERNAME or OPENFEED_PASSWORD" -> check `.env` at the repo
  root has both values filled in.
- Re-running `setup.command` is safe - it skips credential setup if `.env`
  already exists.
