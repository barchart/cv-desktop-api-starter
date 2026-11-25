"""Installs a downloaded version of this project over your copy. update.py (the
copy you already have) downloads the new version, then runs this script from
inside the download - so this is the new version's install step.

    install_update.py <new version's folder> <your project folder> <version name> [<release notes>]

These arguments are a contract: copies of update.py already out there call
every future version of this script exactly like this.

- Copies every file of the new version over your folder, without touching your
  own files (my-scripts/, .env, venv/).
- Every file it replaces or removes is saved in previous-version/ first.
- If you changed one of the examples, your version is moved to my-scripts/.
- Then runs the new version's project_setup.py, which updates the venv.
Standard library only."""

import shutil
import subprocess
import sys
from pathlib import Path

# This script's own folder (inside the download) comes first on the import path,
# so this is the new version's project_files.py.
from project_files import free_name, hash_file, hash_project_files, list_project_files, read_installed, write_installed

# Run setup with the Python behind the venv, so it can rebuild the venv if needed.
BASE_PYTHON = getattr(sys, "_base_executable", sys.executable)


def copy(source: Path, target: Path) -> None:
    target.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(source, target)


def install(new_dir: Path, project_dir: Path) -> dict:
    """Copies the new version's files over the project and removes the ones it no longer has."""
    installed = (read_installed(project_dir) or {}).get("files", {})
    backup_dir, my_scripts_dir = project_dir / "previous-version", project_dir / "my-scripts"
    changes = {"count": 0, "kept_edits": [], "replaced_edits": []}
    backup_started = False

    def back_up(rel: str) -> None:
        nonlocal backup_started
        if not backup_started:
            shutil.rmtree(backup_dir, ignore_errors=True)
            backup_started = True
        copy(project_dir / rel, backup_dir / rel)

    new_files = list_project_files(new_dir)
    for rel in new_files:
        local, incoming = project_dir / rel, new_dir / rel
        if local.is_file():
            local_hash = hash_file(local)
            if local_hash == hash_file(incoming):
                continue
            back_up(rel)
            # Changed since setup or the last update, so by you.
            edited = rel in installed and installed[rel] != local_hash
            if edited and rel.startswith("examples/"):
                my_scripts_dir.mkdir(exist_ok=True)
                name = free_name(my_scripts_dir, Path(rel).name)
                copy(local, my_scripts_dir / name)
                changes["kept_edits"].append((rel, name))
            elif edited:
                changes["replaced_edits"].append(rel)
        copy(incoming, local)
        changes["count"] += 1

    still_there = set(new_files)
    for rel in installed:
        local = project_dir / rel
        if rel in still_there or not local.is_file():
            continue
        back_up(rel)
        local.unlink()
        changes["count"] += 1
    return changes


def report(changes: dict, version: str) -> None:
    if changes["count"] == 0:
        print(f"Already up to date ({version}).")
        return
    print(f"\n{changes['count']} file(s) updated. The previous versions are saved in previous-version/.")
    for rel, name in changes["kept_edits"]:
        print(f"\nYou had changed {rel}. Your version is now my-scripts/{name}")
        print(f"(run it with: cvdesk-py {Path(name).stem.replace('_', '-')}), and {rel} is the new version.")
    if changes["replaced_edits"]:
        print("\nYou had changed these project files. They were replaced; your versions are in previous-version/:")
        for rel in changes["replaced_edits"]:
            print(f"  {rel}")


def main() -> None:
    # Keep this script's output in order with the setup step's, also when piped.
    sys.stdout.reconfigure(line_buffering=True)
    new_dir, project_dir, version = Path(sys.argv[1]).resolve(), Path(sys.argv[2]).resolve(), sys.argv[3]
    notes = sys.argv[4] if len(sys.argv) > 4 else ""

    changes = install(new_dir, project_dir)
    write_installed({"version": version, "files": hash_project_files(new_dir)}, project_dir)
    report(changes, version)
    if changes["count"] > 0 or (project_dir / "src").is_dir():
        # The setup script that just arrived: update the venv, move old scripts out of src/.
        setup = subprocess.run([BASE_PYTHON, str(project_dir / "scripts" / "project_setup.py")])
        if setup.returncode != 0:
            sys.exit("\nThe files were updated, but setting them up failed. Run the setup script again.")
    if changes["count"] > 0:
        print(f"\nUpdated to {version}.")
        if notes:
            print(f"\nWhat's new:\n{notes}")


if __name__ == "__main__":
    main()
