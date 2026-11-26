"""Which files in this folder belong to the project (replaced by `cvdesk update`)
and which are yours (never touched). Used by project_setup.py and update.py.
Standard library only, so it works before the venv exists."""

import hashlib
import json
import os
from pathlib import Path

PROJECT_DIR = Path(__file__).resolve().parent.parent
MY_SCRIPTS_DIR = PROJECT_DIR / "my-scripts"
EXAMPLES_DIR = PROJECT_DIR / "examples"
BACKUP_DIR = PROJECT_DIR / "previous-version"
VENV_DIR = PROJECT_DIR / "venv"
INSTALLED_FILE = PROJECT_DIR / ".cvdesk-installed.json"
VENV_PYTHON = VENV_DIR / ("Scripts/python.exe" if os.name == "nt" else "bin/python")

# Never replaced or removed by an update. src/ is where older versions kept scripts.
YOURS = {"my-scripts", "venv", "previous-version", "src", ".env", ".cvdesk-installed.json"}
IGNORED = {".DS_Store", "Thumbs.db", "__pycache__"}


def list_project_files(directory: Path) -> list[str]:
    """Every project file under directory, as paths relative to it with forward slashes."""
    files = []

    def walk(rel: str) -> None:
        for entry in sorted((directory / rel).iterdir()):
            if entry.name in IGNORED or (rel == "" and entry.name in YOURS):
                continue
            child = f"{rel}/{entry.name}" if rel else entry.name
            if entry.is_dir():
                walk(child)
            elif entry.is_file():
                files.append(child)

    walk("")
    return files


def hash_file(file: Path) -> str:
    return hashlib.sha256(file.read_bytes()).hexdigest()


def hash_project_files(directory: Path = PROJECT_DIR) -> dict[str, str]:
    return {rel: hash_file(directory / rel) for rel in list_project_files(directory)}


def read_installed(project_dir: Path = PROJECT_DIR) -> dict | None:
    """What the last setup or update installed: {"version": ..., "files": {"path": sha256}}."""
    try:
        return json.loads((project_dir / INSTALLED_FILE.name).read_text(encoding="utf-8"))
    except (OSError, ValueError):
        return None


def write_installed(installed: dict, project_dir: Path = PROJECT_DIR) -> None:
    (project_dir / INSTALLED_FILE.name).write_text(json.dumps(installed, indent=2) + "\n", encoding="utf-8")


def free_name(directory: Path, name: str) -> str:
    """name if it's free in directory, otherwise name-2, name-3, ... (before the extension)."""
    stem, suffix = Path(name).stem, Path(name).suffix
    candidate, i = name, 2
    while (directory / candidate).exists():
        candidate = f"{stem}-{i}{suffix}"
        i += 1
    return candidate
