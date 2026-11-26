"""The setup steps shared by setup.command, setup.bat and `cvdesk update python`:
- creates my-scripts/, the folder for your own scripts, which updates never touch
- moves scripts from src/ (where they lived in older versions) into my-scripts/
- creates the venv, or rebuilds it if it was made with a different Python
- installs dependencies and the latest barchart-desktop-sdk
- records which files came with the project (see update.py), if not done yet
Run with the Python the venv should use, not the venv's own Python.
Standard library only, so it works before the venv exists."""

import shutil
import subprocess
import sys

MIN_VERSION = (3, 11)
if sys.version_info < MIN_VERSION:
    sys.exit(f"ERROR: Python {'.'.join(map(str, MIN_VERSION))} or newer is required (found {sys.version.split()[0]}).")

from project_files import (  # noqa: E402 - after the version check, so old Pythons get the message above
    EXAMPLES_DIR, MY_SCRIPTS_DIR, PROJECT_DIR, VENV_DIR, VENV_PYTHON,
    free_name, hash_project_files, read_installed, write_installed,
)

SDK = "barchart-desktop-sdk"
# When run from inside the venv (by `cvdesk update python`), build with the Python behind it.
BASE_PYTHON = getattr(sys, "_base_executable", sys.executable) if sys.prefix != sys.base_prefix else sys.executable
QUIET_PIP = ["--disable-pip-version-check", "--no-input", "-q"]


def main() -> None:
    # Keep this script's output in order with pip's, also when piped.
    sys.stdout.reconfigure(line_buffering=True)
    MY_SCRIPTS_DIR.mkdir(exist_ok=True)
    move_old_scripts()
    ensure_venv()
    install_dependencies()
    if read_installed() is None:
        write_installed({"version": "unknown", "files": hash_project_files()})


def move_old_scripts() -> None:
    """Older versions kept everyone's scripts in src/, next to the examples.
    Files identical to an example are dropped; everything else moves to my-scripts/."""
    src_dir = PROJECT_DIR / "src"
    if not src_dir.is_dir():
        return
    moved = []
    for entry in sorted(src_dir.iterdir()):
        if entry.name in {".DS_Store", "__pycache__"}:
            continue
        example = EXAMPLES_DIR / entry.name
        if entry.is_file() and example.is_file() and entry.read_bytes() == example.read_bytes():
            entry.unlink()
            continue
        target = free_name(MY_SCRIPTS_DIR, entry.name)
        entry.rename(MY_SCRIPTS_DIR / target)
        moved.append(target)
    shutil.rmtree(src_dir, ignore_errors=True)
    if moved:
        print("\nMoved your scripts from src/ to my-scripts/:")
        for name in moved:
            print(f"  {name}")


def venv_version() -> str | None:
    if not VENV_PYTHON.exists():
        return None
    result = subprocess.run([str(VENV_PYTHON), "-c", "import sys; print(sys.version)"], capture_output=True, text=True)
    return result.stdout.strip() if result.returncode == 0 else None


def ensure_venv() -> None:
    """A venv stays on the Python it was created with, so rebuild it when that changed."""
    current = venv_version()
    if current == sys.version:
        return
    wanted = sys.version.split()[0]
    if current:
        print(f"\nThe venv uses Python {current.split()[0]} - recreating it with Python {wanted}...")
    elif VENV_DIR.exists():
        print(f"\nThe venv no longer works - recreating it with Python {wanted}...")
    else:
        print(f"\nCreating the venv with Python {wanted}...")
    shutil.rmtree(VENV_DIR, ignore_errors=True)
    if subprocess.run([BASE_PYTHON, "-m", "venv", str(VENV_DIR)]).returncode != 0:
        sys.exit("Creating the venv failed.")


def pip(*args: str, quiet_errors: bool = False) -> bool:
    stderr = subprocess.DEVNULL if quiet_errors else None
    return subprocess.run([str(VENV_PYTHON), "-m", "pip", *args, *QUIET_PIP], cwd=PROJECT_DIR, stderr=stderr).returncode == 0


def installed_version(package: str) -> str | None:
    code = f"import importlib.metadata as m\ntry: print(m.version({package!r}))\nexcept m.PackageNotFoundError: pass"
    return subprocess.run([str(VENV_PYTHON), "-c", code], capture_output=True, text=True).stdout.strip() or None


def install_dependencies() -> None:
    print("\nInstalling dependencies...")
    pip("install", "--upgrade", "pip", quiet_errors=True)
    if not pip("install", "-r", "requirements.txt"):
        sys.exit("pip install failed.")

    print(f"\nChecking for the latest {SDK}...")
    current = installed_version(SDK)
    if not pip("install", "--upgrade", SDK, quiet_errors=True):
        print(f"Could not reach PyPI, keeping version {current}.")
        return
    latest = installed_version(SDK)
    print(f"Up to date ({latest})." if latest == current else f"Updated {current} -> {latest}.")


if __name__ == "__main__":
    main()
