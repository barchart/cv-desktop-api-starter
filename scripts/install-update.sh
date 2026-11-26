#!/usr/bin/env bash
# Installs a downloaded version of the whole project over your copy. update.sh
# (the copy you already have) downloads the new version, then runs this script
# from inside the download - so this is the new version's install step.
#
#   install-update.sh <new version's folder> <your project folder> <version name> [<release page URL>]
#
# These arguments are a contract: copies of update.sh already out there call
# every future version of this script exactly like this.
#
# - Updates the files at the top of the project (README.md, update.command, bin/, scripts/).
# - Then runs each language folder's own install step from the download, the same
#   one that folder's own update runs:
#   - TypeScript and Python only if you ran their setup, since their update also
#     updates their dependencies (node_modules, venv).
#   - Java, Go and C# always: they have nothing to set up.
# - Records the version in .cvdesk-installed.
# - Puts the cvdesk command on PATH, if it isn't yet.
set -e
NEW="$(cd "$1" && pwd)"
PROJECT="$(cd "$2" && pwd)"
VERSION="$3"
URL="$4"
UPDATED=""
SKIPPED=""
FAILED=""

section() {
  echo
  echo "=== $1 ==="
}

# Runs a language's install step and notes whether it worked.
run() {
  local name="$1"
  shift
  if "$@"; then
    UPDATED="$UPDATED, $name"
  else
    FAILED="$FAILED, $name"
  fi
}

skip() {
  echo "$2"
  SKIPPED="$SKIPPED, $1"
}

# The files at the top of the project. Nobody edits these, but every one replaced
# is saved in previous-version/ anyway.
section "Project files"
COUNT=0
BACKED_UP=""
while IFS= read -r rel; do
  if [ -f "$PROJECT/$rel" ]; then
    cmp -s "$NEW/$rel" "$PROJECT/$rel" && continue
    if [ -z "$BACKED_UP" ]; then
      rm -rf "$PROJECT/previous-version"
      BACKED_UP=1
    fi
    mkdir -p "$PROJECT/previous-version/$(dirname "$rel")"
    cp -p "$PROJECT/$rel" "$PROJECT/previous-version/$rel"
  fi
  mkdir -p "$PROJECT/$(dirname "$rel")"
  cp -p "$NEW/$rel" "$PROJECT/$rel"
  COUNT=$((COUNT + 1))
done < <(cd "$NEW" && { find . -maxdepth 1 -type f; find bin scripts -type f 2> /dev/null; } | sed 's#^\./##' |
  grep -v -e '\.DS_Store$' -e 'Thumbs\.db$' | LC_ALL=C sort)
if [ "$COUNT" -eq 0 ]; then
  echo "Already up to date."
else
  echo "$COUNT file(s) updated."
fi

section "TypeScript"
if [ ! -f "$NEW/typescript/scripts/install-update.mjs" ] || [ ! -d "$PROJECT/typescript" ]; then
  skip TypeScript "Not in this version."
elif [ ! -f "$PROJECT/typescript/.cvdesk-installed.json" ]; then
  skip TypeScript "Not set up, so not updated. If you start using it, run its setup, then update again."
elif ! command -v node > /dev/null; then
  skip TypeScript "Node.js isn't installed, so not updated."
else
  run TypeScript node "$NEW/typescript/scripts/install-update.mjs" "$NEW/typescript" "$PROJECT/typescript" "$VERSION"
fi

section "Python"
if [ ! -f "$NEW/python/scripts/install_update.py" ] || [ ! -d "$PROJECT/python" ]; then
  skip Python "Not in this version."
elif [ ! -f "$PROJECT/python/.cvdesk-installed.json" ]; then
  skip Python "Not set up, so not updated. If you start using it, run its setup, then update again."
elif [ ! -x "$PROJECT/python/venv/bin/python" ]; then
  skip Python "Its venv is missing, so not updated. Run python/setup.command, then update again."
else
  run Python "$PROJECT/python/venv/bin/python" "$NEW/python/scripts/install_update.py" "$NEW/python" "$PROJECT/python" "$VERSION"
fi

for lang in "java Java" "go Go" "csharp C#"; do
  folder="${lang%% *}"
  name="${lang#* }"
  section "$name"
  if [ ! -f "$NEW/$folder/scripts/install-update.sh" ] || [ ! -d "$PROJECT/$folder" ]; then
    skip "$name" "Not in this version."
  else
    run "$name" bash "$NEW/$folder/scripts/install-update.sh" "$NEW/$folder" "$PROJECT/$folder" "$VERSION"
  fi
done

echo
echo "=== Done ==="
[ -z "$UPDATED" ] || echo "Up to date with $VERSION: ${UPDATED#, }."
[ -z "$SKIPPED" ] || echo "Skipped: ${SKIPPED#, } (see above)."
if [ -n "$FAILED" ]; then
  echo "Failed: ${FAILED#, } (see above). Run ./update.command again to retry."
  exit 1
fi
echo "version $VERSION" > "$PROJECT/.cvdesk-installed"
[ -z "$URL" ] || echo "What's new: $URL"
# The cvdesk command, which replaces the cvdesk-py command and the TypeScript-only
# cvdesk of earlier versions: put it on PATH, if it isn't yet.
if [ -f "$PROJECT/scripts/add-to-path.sh" ]; then
  bash "$PROJECT/scripts/add-to-path.sh" --if-needed
fi
