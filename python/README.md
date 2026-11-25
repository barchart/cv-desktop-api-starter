# Python Starter - Quick Notes

## Where things are
- [examples/](examples/) - example scripts that come with the project, such as
  [examples/start_guide.py](examples/start_guide.py) and
  [examples/desktop_sdk.py](examples/desktop_sdk.py). `cvdesk-py update` replaces
  them with their newest versions.
- `my-scripts/` - **your own scripts go here.** Setup creates it, and updates never
  touch it.

To change an example, copy it into `my-scripts/` first and change the copy.
`cvdesk-py start-guide` then runs your copy, because `my-scripts/` comes first.
If you change an example in place anyway, `cvdesk-py update` moves your version
into `my-scripts/` before it installs the new one, so nothing is lost.

## Prerequisite
Python 3.11 or newer. macOS comes with an older `python3` (3.9) that is too old
for the Barchart Desktop SDK, so install a newer one from
[python.org](https://www.python.org/downloads/) or with Homebrew
(`brew install python`). The macOS setup script finds the newest Python you
have installed, even if plain `python3` still runs the old one. On Windows it
uses the newest one the `py` launcher knows about. It also finds a Python
installed with [uv](https://docs.astral.sh/uv/).

If setup finds no Python 3.11 or newer, it offers to install one for you with
uv, which needs no admin rights and installs into your home folder. Answer `y`
to let it download uv and then the Python version in
[.python-version](.python-version). Answer `n` to install Python yourself
instead.

If you install a newer Python later, run the setup script again: it rebuilds
the `venv` folder with the new version. Packages you added to the `venv`
yourself need installing again after that.

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

This checks your setup, creates a `venv` folder with the dependencies, and
installs the `cvdesk-py` command, which runs any script in `my-scripts/` or
`examples/` from any folder (see below). It adds this project's `bin/` folder
to your PATH: in `~/.zshrc` on macOS, in your user environment variables on
Windows. Open a new terminal window afterwards to use it. If you move this
folder, run setup again. If you have more than one copy of this project,
`cvdesk-py` runs the one you last ran setup in.

`cvdesk-py` always runs scripts with this project's `venv`, so there's no need
to activate it first.

## Add your credentials
Copy [examples/start_guide.py](examples/start_guide.py) into `my-scripts/`, open the
copy and replace `YOUR_USERNAME` / `YOUR_PASSWORD` (`USERNAME` and `PASSWORD` -
search the file for `YOUR_USERNAME`) with your cmdtyView Desktop API credentials.
Do the same in any new script you add.

## Run it
From any folder:
```bash
cvdesk-py start-guide
```

## Your own scripts
Put any number of `.py` files in `my-scripts/` and run each one from any folder,
with optional arguments:
```bash
cvdesk-py my_script arg1 arg2
cvdesk-py                # lists the scripts in my-scripts/ and examples/
```
New scripts work straight away; there's no need to re-run setup. A script's name
can be written with `-` instead of `_`: `cvdesk-py my-script` runs `my_script.py`.

`cvdesk-py` also runs `.py` files anywhere else on your computer: give it the
file's path instead of a name. Those scripts can import the same packages as
the scripts in `my-scripts/` (for example `barchart_desktop_sdk`).
```bash
cvdesk-py ./my_script.py            # relative to the folder you're in
cvdesk-py ~/Desktop/test.py arg1    # or a full path
```

To use the `venv` directly instead, for example to `pip install` another
package, activate it from inside this folder:
```bash
source venv/bin/activate   # macOS
venv\Scripts\activate      # Windows
```

## Getting the newest version
From any folder:
```bash
cvdesk-py update
```
This downloads the newest version of the project from GitHub (the latest
release, or the main branch if there are no releases), installs it, and
updates the `venv`'s dependencies. It never touches `my-scripts/`, `.env` or
packages you installed into the `venv` yourself. Every file it replaces or
removes is saved in `previous-version/` first.

If you downloaded the project as a zip yourself (GitHub's **Code -> Download ZIP**),
install it with:
```bash
cvdesk-py update --from ~/Downloads/cv-desktop-api-starter-main.zip
```

Since `update` is the command's own name, a script called `update.py` can only be
run by its path: `cvdesk-py ./my-scripts/update.py`.

## Coming from an older version (scripts in `src/`)
Older versions kept everyone's scripts in `src/`, and they don't have `cvdesk-py update`.
Download the new version once more, unzip it **over your existing folder**, and run
the setup script again. Setup moves your scripts from `src/` into `my-scripts/`.
From then on, `cvdesk-py update` does the rest.

## Troubleshooting
- "Invalid credentials" or login rejected -> check the username and password
  you entered in `my-scripts/start_guide.py`.
- "No module named ..." -> run the setup script again.
- Re-running the setup script is safe.
