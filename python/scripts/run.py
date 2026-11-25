"""Runs a script with the venv's Python, so its packages are always there and
the venv never needs activating. The script is either a file path (relative to
the current folder, or absolute) or the name of a script in my-scripts/ or
examples/: `my_script`, `my_script.py`, or `my-script` for my_script.py.
my-scripts/ wins if both have one. Without one, it lists the scripts.
`run.py update` runs update.py instead, so a script named update.py can
only be run by its path. Works from any directory, so the cvdesk-py command uses it."""

import subprocess
import sys
from pathlib import Path

PROJECT_DIR = Path(__file__).resolve().parent.parent
SCRIPT_DIRS = ["my-scripts", "examples"]


def scripts_in(directory: str) -> dict[str, Path]:
    """Script files in a folder, by name (the file name without .py)."""
    folder = PROJECT_DIR / directory
    return {f.stem: f for f in sorted(folder.glob("*.py")) if f.is_file()} if folder.is_dir() else {}


def find_script(arg: str) -> Path | None:
    if Path(arg).is_file():
        return Path(arg).resolve()
    name = Path(arg).name.removesuffix(".py")
    for candidate in (name, name.replace("-", "_")):
        for directory in SCRIPT_DIRS:
            if candidate in (scripts := scripts_in(directory)):
                return scripts[candidate]
    return None


def usage(script_arg: str | None) -> None:
    if script_arg:
        print(f'No file "{script_arg}" here and no script by that name in {"/ or ".join(SCRIPT_DIRS)}/\n', file=sys.stderr)
    print("Usage: cvdesk-py <script name or file path> [arguments]", file=sys.stderr)
    print("       cvdesk-py update     (installs the newest version of this project)", file=sys.stderr)
    for directory in SCRIPT_DIRS:
        print(f"\nScripts in {directory}/:", file=sys.stderr)
        scripts = scripts_in(directory)
        if not scripts:
            print("  (none yet)", file=sys.stderr)
        for name in scripts:
            print(f"  {name}", file=sys.stderr)


def main() -> int:
    script_arg, *args = sys.argv[1:] or [None]
    if script_arg == "update":
        file = PROJECT_DIR / "scripts" / "update.py"
    else:
        file = find_script(script_arg) if script_arg else None
    if file is None:
        usage(script_arg)
        return 1
    try:
        # The script's own folder comes first on its import path, so it can import files next to it.
        return subprocess.run([sys.executable, str(file), *args]).returncode
    except KeyboardInterrupt:
        # Ctrl+C reached the script too; it has already reported it.
        return 130


if __name__ == "__main__":
    sys.exit(main())
