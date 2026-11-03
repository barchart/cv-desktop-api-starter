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
- **Windows**: open PowerShell, `cd` into this `python` folder (see the root
  [README](../README.md#getting-started-no-programming-experience-needed) if
  you're not sure how), then run:
  ```powershell
  .\setup.bat
  ```

This checks your setup and creates a `venv` folder with dependencies installed.

## Add your credentials
Open [src/start_guide.py](src/start_guide.py) and replace `YOUR_USERNAME` / `YOUR_PASSWORD`
(`USERNAME` and `PASSWORD` - search the file for `YOUR_USERNAME`) with your cmdtyView Desktop API credentials.
Do the same in any new script you add.

## Run it
```bash
source venv/bin/activate   # macOS/Linux
venv\Scripts\activate.bat  # Windows

python3 src/start_guide.py
```

## Troubleshooting
- "Invalid credentials" or login rejected -> check the username and password
  you entered in `src/start_guide.py`.
- Re-running the setup script is safe.
