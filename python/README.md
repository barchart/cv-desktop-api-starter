# Python Starter - Quick Notes

## Source code
The actual program is [src/start_guide.py](src/start_guide.py). Open it in any
text editor or VS Code, change something (e.g. the code that decides what to
print), save, then re-run it with the command under "Run it" below to see
your change take effect.

## Prerequisite
Python 3.9+. On macOS, `python3` may exist as a placeholder even without Xcode
Command Line Tools installed - if `setup.command` errors out, accept the
"Install Command Line Developer Tools" popup if you see one, then re-run it.

## First-time setup
- **macOS**: open Terminal, `cd` into this `python` folder (see the root
  [README](../README.md#getting-started-no-programming-experience-needed) if
  you're not sure how), then run:
  ```bash
  ./setup.command
  ```
- **Windows**: double-click `setup.bat`

This asks for your OpenFeed credentials (saved to `.env` in this folder and at
the repo root) and creates a `venv` folder with dependencies installed.

## Run it
```bash
source venv/bin/activate   # macOS/Linux
venv\Scripts\activate.bat  # Windows

python3 src/start_guide.py
```

## Troubleshooting
- "Missing OPENFEED_USERNAME or OPENFEED_PASSWORD" -> check `.env` in this
  folder has both values filled in.
- Re-running `setup.command` is safe - it'll ask whether to set fresh
  credentials, or you can just edit `.env` in this folder by hand.
