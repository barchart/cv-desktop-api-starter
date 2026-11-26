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
# - Leaves everything else alone: build output, .env, my-scripts/, files you added.
# - Earlier versions kept the start guide elsewhere (see below). If you had
#   changed it, it is moved into my-scripts/, so cvdesk runs your version.
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

# Earlier versions kept the start guide somewhere else, and you may have added
# your credentials to it there. If you had changed it, move it into my-scripts/
# (with the lines cvdesk needs to run it), so it isn't lost and cvdesk runs it
# instead of the new examples/ version. One that is still as it came is removed.
if [ -f "$NEW/go.mod" ]; then
  OLD_GUIDE="cmd/start-guide/main.go" GUIDE="start-guide.go"
  ORIGINALS="2e2fe9699b2258a3750f6d6fbc119b490275947eb9a737b3db70f648abd2a25e 84b33f1392f34f78207863ed9b3e9e277b94ce9c5706b51e1c7304394296b2cf 9287150172055bba56ce4ca21f0345334f587fd56fab19697108422129855612 c506deffa889e319a6a8d1f3fdfad1c1cc459d48e7877051b6d495800d1c82f4"
elif [ -f "$NEW/pom.xml" ]; then
  OLD_GUIDE="src/main/java/com/barchart/openfeed/StartGuide.java" GUIDE="StartGuide.java"
  ORIGINALS="59c97456380f569e398175167d00b0c1a4aea0a83549cd5b7e0420e18fa7ca4a 8a02b8902c73f35f986c2b71ae938b2406252ceea797c32364b871e06a49cc4a ad58d993633945cfecaa0770efa2b6372068030ac22d0041cd2a5015d6f9cb2d"
else
  OLD_GUIDE="OpenFeedStartGuide/Program.cs" GUIDE="start-guide.cs"
  ORIGINALS="8d625a534a0374857a92c376cd918bdae97ef1d6c519af54b96e41e160fb4a8b a666961ead9c4fa9ba396d4a64482fad7b24863cba489fd57ca6c24546027b2c c69ce18f809721201659466e7fa003d688a0af558ae824f16e0567070c154690"
fi
MOVED_GUIDE=""
if [ -f "$PROJECT/$OLD_GUIDE" ] && [ ! -f "$NEW/$OLD_GUIDE" ]; then
  if ! case " $ORIGINALS " in *" $(hash_of "$PROJECT/$OLD_GUIDE") "*) true ;; *) false ;; esac; then
    mkdir -p "$PROJECT/my-scripts"
    MOVED_GUIDE="$GUIDE"
    i=2
    while [ -e "$PROJECT/my-scripts/$MOVED_GUIDE" ]; do
      MOVED_GUIDE="${GUIDE%.*}-$i.${GUIDE##*.}"
      i=$((i + 1))
    done
    case "$GUIDE" in
      *.go) { grep -q '^//go:build' "$PROJECT/$OLD_GUIDE" || printf '//go:build ignore\n\n'; cat "$PROJECT/$OLD_GUIDE"; } ;;
      *.java) awk '!done && /^package [A-Za-z0-9_.]+;/ { done = 1; next } { print }' "$PROJECT/$OLD_GUIDE" ;;
      *.cs) { grep -q '^#:package' "$PROJECT/$OLD_GUIDE" || printf '#:package openfeed.net@*\n#:property PublishAot=false\n\n'; cat "$PROJECT/$OLD_GUIDE"; } ;;
    esac > "$PROJECT/my-scripts/$MOVED_GUIDE"
  fi
  back_up "$OLD_GUIDE"
  rm -f "$PROJECT/$OLD_GUIDE"
fi

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

if [ -n "$MOVED_GUIDE" ]; then
  echo
  echo "You had changed $OLD_GUIDE, where earlier versions kept the start guide."
  echo "Your version is now my-scripts/$MOVED_GUIDE (run it with: cvdesk $MOVED_GUIDE)."
fi
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
