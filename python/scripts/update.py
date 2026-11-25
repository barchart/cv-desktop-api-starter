"""`cvdesk-py update`: downloads the newest version of this project from GitHub and
installs it over this folder, without touching your own files (my-scripts/,
.env, venv/). It takes the latest GitHub release, or the main branch if the
project has no releases.
- Every file it replaces or removes is saved in previous-version/ first.
- If you changed one of the examples, your version is moved to my-scripts/.
`cvdesk-py update --from <file>` installs a .zip or .tar.gz of the project you
downloaded yourself, for example from GitHub's "Download ZIP".
This file only downloads. The installing is done by install_update.py from the
version it downloads, so each new version brings its own install steps. Keep
this file simple: copies of it already out there have to keep working with
every future version. Standard library only."""

import json
import ssl
import subprocess
import sys
import tarfile
import tempfile
import urllib.error
import urllib.request
import zipfile
from pathlib import Path

from project_files import PROJECT_DIR, read_installed

REPO = "barchart/cv-desktop-api-starter"
FOLDER_IN_REPO = "python"


def fail(message: str):
    sys.exit(message)


def ssl_context() -> ssl.SSLContext:
    # python.org's macOS installer ships without CA certificates until you run its
    # "Install Certificates" step; pip's own copy of certifi works either way.
    try:
        import certifi
    except ImportError:
        try:
            from pip._vendor import certifi
        except ImportError:
            return ssl.create_default_context()
    return ssl.create_default_context(cafile=certifi.where())


CONTEXT = ssl_context()


def get(url: str, headers: dict | None = None, allow404: bool = False):
    request = urllib.request.Request(url, headers={"User-Agent": "cvdesk-update", **(headers or {})})
    try:
        return urllib.request.urlopen(request, context=CONTEXT, timeout=60)
    except urllib.error.HTTPError as error:
        if error.code == 404 and allow404:
            return None
        if error.code == 404:
            fail(f"Could not find github.com/{REPO}. Is the project still public?")
        if error.code in (403, 429):
            fail("GitHub is limiting update checks from your network right now. Try again in an hour.")
        fail(f'GitHub answered "{error.code} {error.reason}". Try again later.')
    except (urllib.error.URLError, OSError) as error:
        fail(f"Could not reach GitHub ({getattr(error, 'reason', error)}). Check your internet connection and try again.")


def github(pathname: str, accept: str = "application/vnd.github+json", allow404: bool = False):
    headers = {"Accept": accept, "X-GitHub-Api-Version": "2022-11-28"}
    return get(f"https://api.github.com/repos/{REPO}{pathname}", headers, allow404)


def find_latest() -> dict:
    """The latest release, or the newest commit on the main branch if there are no releases."""
    release = github("/releases/latest", allow404=True)
    if release:
        data = json.load(release)
        return {"ref": data["tag_name"], "version": data["tag_name"], "notes": (data.get("body") or "").strip()}
    sha = github("/commits/HEAD", accept="application/vnd.github.sha").read().decode().strip()
    return {"ref": sha, "version": f"commit {sha[:7]}", "notes": ""}


def extract(archive: Path, out: Path, name: str) -> Path:
    """Unpacks the archive and returns the project folder inside it."""
    out.mkdir()
    try:
        if zipfile.is_zipfile(archive):
            with zipfile.ZipFile(archive) as z:
                z.extractall(out)
        else:
            with tarfile.open(archive) as tar:
                try:
                    tar.extractall(out, filter="data")
                except TypeError:  # Python 3.11 before 3.11.4 has no filter argument
                    tar.extractall(out)
    except (OSError, tarfile.TarError, zipfile.BadZipFile):
        fail(f"Could not unpack {name}.")
    # GitHub's archives hold one folder with the whole project; this one is in python/ inside it.
    candidates = [out, *sorted(p for p in out.iterdir() if p.is_dir())]
    for directory in (d for c in candidates for d in (c, c / FOLDER_IN_REPO)):
        if (directory / "scripts" / "install_update.py").is_file() and (directory / "requirements.txt").is_file():
            return directory
    fail(f"{name} doesn't contain this project.")


def main() -> None:
    # Keep this script's output in order with the setup step's, also when piped.
    sys.stdout.reconfigure(line_buffering=True)
    args = sys.argv[1:]
    notes = ""
    with tempfile.TemporaryDirectory(prefix="cvdesk-update-") as tmp:
        tmp = Path(tmp)
        if "--from" in args:
            index = args.index("--from")
            source = Path(args[index + 1]).expanduser().resolve() if index + 1 < len(args) else None
            if source is None or not source.is_file():
                fail("Usage: cvdesk-py update --from <downloaded .zip or .tar.gz file>")
            archive, version, name = source, f"file {source.name}", str(source)
        else:
            print("Checking for a new version...")
            latest = find_latest()
            if (read_installed() or {}).get("version") == latest["version"]:
                print(f"Already up to date ({latest['version']}).")
                return
            print(f"Downloading {latest['version']}...")
            archive = tmp / "download.tar.gz"
            # The plain download link, which (unlike the API) doesn't count toward GitHub's hourly limit.
            with get(f"https://github.com/{REPO}/archive/{latest['ref']}.tar.gz") as response:
                archive.write_bytes(response.read())
            version, notes, name = latest["version"], latest["notes"], "The downloaded version"

        new_dir = extract(archive, tmp / "extracted", name)
        # The new version's own install step (see install_update.py for the arguments).
        install = [sys.executable, str(new_dir / "scripts" / "install_update.py"), str(new_dir), str(PROJECT_DIR), version]
        result = subprocess.run(install + ([notes] if notes else []))
    sys.exit(result.returncode)


if __name__ == "__main__":
    main()
