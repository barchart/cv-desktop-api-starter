#!/usr/bin/env bash
# Puts this project's bin/ folder on your PATH, so the cvdesk command works in
# any new terminal. Called by every language's setup.command, and with
# --if-needed by updates (which then change nothing, quietly, if it is already
# set up for this copy).
# The copy of this project you last ran setup in wins: the PATH lines earlier
# setups added (for this or any other copy, including the ones older versions
# added for typescript/bin, and for python/bin: the cvdesk-py command, which
# cvdesk replaces) are removed, then this one is added at the end, where it
# comes first.
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
chmod +x "$ROOT/bin/cvdesk"
PROFILE="$HOME/.zshrc"
[ "$(basename "$SHELL")" = "bash" ] && PROFILE="$HOME/.bash_profile"
MARKER="# cmdtyView Desktop API starter: cvdesk command"
OLD_TS="# cmdtyView Desktop API TypeScript starter: cvdesk command"
OLD_PY="# cmdtyView Desktop API Python starter: cvdesk-py command"
if [ "$1" = "--if-needed" ] && [ -f "$PROFILE" ] && grep -qxF "$MARKER" "$PROFILE" &&
  grep -qxF "export PATH=\"$ROOT/bin:\$PATH\"" "$PROFILE" &&
  ! grep -qxF -e "$OLD_TS" -e "$OLD_PY" "$PROFILE"; then
  exit 0
fi
if [ -f "$PROFILE" ]; then
  CLEANED="$(awk -v m1="$MARKER" -v m2="$OLD_TS" -v m3="$OLD_PY" '
    skip { skip = 0; if (index($0, "export PATH=") == 1) next }
    $0 == m1 || $0 == m2 || $0 == m3 { pending = 0; skip = 1; next }
    { if (pending) print ""; pending = 0 }
    $0 == "" { pending = 1; next }
    { print }
    END { if (pending) print "" }' "$PROFILE")"
  # Rewrite in place (not mv), so a profile that is a symlink stays one.
  printf '%s\n' "$CLEANED" > "$PROFILE"
fi
printf '\n%s\nexport PATH="%s/bin:$PATH"\n' "$MARKER" "$ROOT" >> "$PROFILE"
echo "cvdesk now runs from $ROOT (set in $PROFILE). Open a new terminal window to use it."
