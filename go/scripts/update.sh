#!/usr/bin/env bash
# Downloads the newest version of this project from GitHub and installs it over
# this folder. It takes the latest GitHub release, or the main branch if the
# project has no releases.
#   update.sh                      (run by ../update.command)
#   update.sh --from <file>        installs a .zip or .tar.gz you downloaded yourself,
#                                  for example from GitHub's "Download ZIP"
# This file only downloads. The installing is done by scripts/install-update.sh
# from the version it downloads, so each new version brings its own install
# steps. Keep this file simple: copies of it already out there have to keep
# working with every future version.
# All of it is inside { }, so bash reads the whole file before running it:
# the update replaces this file while it runs.
{
set -e
REPO="barchart/cv-desktop-api-starter"
FOLDER_IN_REPO="go"
PROJECT="$(cd "$(dirname "$0")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

fail() {
  echo "$1" >&2
  exit 1
}

# Downloads url to file and prints the HTTP status.
http() {
  local url="$1" out="$2"
  shift 2
  local args=(-sSL -o "$out" -w '%{http_code}' -H "User-Agent: cvdesk-update")
  for header in "$@"; do args+=(-H "$header"); done
  curl "${args[@]}" "$url" 2>"$TMP/curl-error" ||
    fail "Could not reach GitHub ($(tr -d '\n' < "$TMP/curl-error")). Check your internet connection and try again."
}

# GitHub API call; returns 4 for "not found".
api() {
  local status
  # `|| exit 1`: set -e is off inside `if api ...`, and http's fail only ends its subshell.
  status="$(http "https://api.github.com/repos/$REPO$1" "$2" "Accept: ${3:-application/vnd.github+json}" "X-GitHub-Api-Version: 2022-11-28")" || exit 1
  case "$status" in
    200) return 0 ;;
    404) return 4 ;;
    403 | 429) fail "GitHub is limiting update checks from your network right now. Try again in an hour." ;;
    *) fail "GitHub answered \"$status\". Try again later." ;;
  esac
}

URL=""
if [ "$1" = "--from" ]; then
  [ -n "$2" ] && [ -f "$2" ] || fail "Usage: ./update.command --from <downloaded .zip or .tar.gz file>"
  ARCHIVE="$(cd "$(dirname "$2")" && pwd)/$(basename "$2")"
  VERSION="file $(basename "$2")"
  NAME="$2"
else
  echo "Checking for a new version..."
  if api /releases/latest "$TMP/release.json"; then
    REF="$(grep -o '"tag_name": *"[^"]*"' "$TMP/release.json" | head -n 1 | sed 's/.*"\([^"]*\)"$/\1/')"
    VERSION="$REF"
    URL="https://github.com/$REPO/releases/tag/$REF"
  else
    [ $? -eq 4 ] || exit 1
    api /commits/HEAD "$TMP/sha" "application/vnd.github.sha" || fail "Could not find github.com/$REPO. Is the project still public?"
    REF="$(tr -d '[:space:]' < "$TMP/sha")"
    VERSION="commit ${REF:0:7}"
  fi
  if [ "$(head -n 1 "$PROJECT/.cvdesk-installed" 2>/dev/null)" = "version $VERSION" ]; then
    echo "Already up to date ($VERSION)."
    exit 0
  fi
  echo "Downloading $VERSION..."
  ARCHIVE="$TMP/download.tar.gz"
  # The plain download link, which (unlike the API) doesn't count toward GitHub's hourly limit.
  STATUS="$(http "https://github.com/$REPO/archive/$REF.tar.gz" "$ARCHIVE")"
  [ "$STATUS" = 200 ] || fail "Downloading failed: GitHub answered \"$STATUS\". Try again later."
  NAME="The downloaded version"
fi

mkdir "$TMP/extracted"
tar -xf "$ARCHIVE" -C "$TMP/extracted" 2>/dev/null || fail "Could not unpack $NAME."
# GitHub's archives hold one folder with the whole project; this one is in $FOLDER_IN_REPO/ inside it.
FOUND=""
for dir in "$TMP/extracted" "$TMP/extracted"/*; do
  for candidate in "$dir" "$dir/$FOLDER_IN_REPO"; do
    if [ -f "$candidate/scripts/install-update.sh" ] &&
      grep -qx "FOLDER_IN_REPO=\"$FOLDER_IN_REPO\"" "$candidate/scripts/update.sh" 2>/dev/null; then
      FOUND="$candidate"
      break 2
    fi
  done
done
[ -n "$FOUND" ] || fail "$NAME doesn't contain this project."

bash "$FOUND/scripts/install-update.sh" "$FOUND" "$PROJECT" "$VERSION" "$URL"
exit
}
