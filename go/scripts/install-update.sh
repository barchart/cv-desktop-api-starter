#!/usr/bin/env bash
# Installs a downloaded version of this project over your copy. update.sh (the
# copy you already have) downloads the new version, then runs this script from
# inside the download - so this is the new version's install step.
#
#   install-update.sh <new version's folder> <your project folder> <version name> [<release page URL>]
#
# These arguments are a contract: copies of update.sh already out there call
# every future version of this script exactly like this.
#
# - Copies every file of the new version over your folder.
# - Removes files an earlier update installed that the new version no longer has.
# - Every file it replaces or removes is saved in previous-version/ first.
# - Leaves everything else alone: build output, .env, files you added.
# - Records what it installed in .cvdesk-installed (the version, then one
#   "sha256  path" line per file), so the next update can tell what you changed.
set -e
NEW="$(cd "$1" && pwd)"
PROJECT="$(cd "$2" && pwd)"
VERSION="$3"
URL="$4"
MANIFEST="$PROJECT/.cvdesk-installed"
BACKUP="$PROJECT/previous-version"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

hash_of() { shasum -a 256 "$1" | cut -d ' ' -f 1; }

# The hash the last update recorded for a file (nothing if there's no record).
installed_hash() {
  [ -f "$MANIFEST" ] && awk -v rel="$1" 'NR > 1 && substr($0, 67) == rel { print $1 }' "$MANIFEST"
  return 0
}

BACKED_UP=""
back_up() {
  if [ -z "$BACKED_UP" ]; then
    rm -rf "$BACKUP"
    BACKED_UP=1
  fi
  mkdir -p "$BACKUP/$(dirname "$1")"
  cp -p "$PROJECT/$1" "$BACKUP/$1"
}

(cd "$NEW" && find . -type f ! -name .DS_Store ! -name Thumbs.db | sed 's#^\./##' | LC_ALL=C sort) > "$WORK/new-files"

COUNT=0
: > "$WORK/edited"
while IFS= read -r rel; do
  if [ -f "$PROJECT/$rel" ]; then
    local_hash="$(hash_of "$PROJECT/$rel")"
    [ "$local_hash" = "$(hash_of "$NEW/$rel")" ] && continue
    back_up "$rel"
    recorded="$(installed_hash "$rel")"
    # Changed since the last update (by you), or no record to compare with.
    if [ -z "$recorded" ] || [ "$recorded" != "$local_hash" ]; then
      echo "$rel" >> "$WORK/edited"
    fi
  fi
  mkdir -p "$PROJECT/$(dirname "$rel")"
  cp -p "$NEW/$rel" "$PROJECT/$rel"
  COUNT=$((COUNT + 1))
done < "$WORK/new-files"

if [ -f "$MANIFEST" ]; then
  while IFS= read -r rel; do
    [ -n "$rel" ] && [ -f "$PROJECT/$rel" ] || continue
    grep -qxF -- "$rel" "$WORK/new-files" && continue
    back_up "$rel"
    rm -f "$PROJECT/$rel"
    COUNT=$((COUNT + 1))
  done < <(tail -n +2 "$MANIFEST" | cut -c 67-)
fi

HAD_RECORD=""
[ -f "$MANIFEST" ] && HAD_RECORD=1
{
  echo "version $VERSION"
  while IFS= read -r rel; do
    printf '%s  %s\n' "$(hash_of "$NEW/$rel")" "$rel"
  done < "$WORK/new-files"
} > "$MANIFEST.tmp"
mv "$MANIFEST.tmp" "$MANIFEST"

if [ "$COUNT" -eq 0 ]; then
  echo "Already up to date ($VERSION)."
  exit 0
fi
echo
echo "$COUNT file(s) updated. The previous versions are saved in previous-version/."
if [ -s "$WORK/edited" ]; then
  echo
  if [ -n "$HAD_RECORD" ]; then
    echo "You had changed these files. They were replaced; your versions are in previous-version/:"
  else
    echo "These files were different from the new version and were replaced. If you had changed"
    echo "any of them (for example to add your credentials), your versions are in previous-version/:"
  fi
  sed 's/^/  /' "$WORK/edited"
fi
echo
echo "Updated to $VERSION."
[ -z "$URL" ] || echo "What's new: $URL"
