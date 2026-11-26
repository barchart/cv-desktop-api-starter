# Python Starter

Setup, credentials, `cvdesk` and updating work the same in every language: see the
[main README](../README.md). This page covers what's specific to Python.

## Needs
Python 3.11+. macOS comes with an older `python3` that is too old, so install one
from [python.org](https://www.python.org/downloads/) or with `brew install python`.
If setup finds no suitable Python, it offers to install one for you with
[uv](https://docs.astral.sh/uv/) (no admin rights needed). Installed a newer
Python later? Run setup again to rebuild the `venv` with it.

## Examples
In [examples/](examples/): [start_guide.py](examples/start_guide.py) (credentials:
`USERNAME` / `PASSWORD`), [desktop_sdk.py](examples/desktop_sdk.py).

## Writing scripts
- `cvdesk` runs scripts with this project's `venv`, so there's no need to activate it.
  Scripts anywhere on your computer get the same packages (such as `barchart_desktop_sdk`).
- To `pip install` another package, activate the venv from this folder first:
  `source venv/bin/activate` (macOS) or `venv\Scripts\activate` (Windows).

## Troubleshooting
- Login rejected -> check the credentials in `my-scripts/start_guide.py`.
- "No module named ..." -> run setup again.
- `cvdesk: command not found` -> open a new terminal window, or run setup again.
- Coming from a version that kept scripts in `src/`? Unzip the new version over
  your folder and run setup again: it moves them into `my-scripts/`.
