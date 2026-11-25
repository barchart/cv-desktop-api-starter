#!/usr/bin/env bash
set -e
cd "$(dirname "$0")"

echo "=== OpenFeed TypeScript Starter Setup ==="
echo

if ! command -v node >/dev/null 2>&1; then
  echo "ERROR: Node.js is not installed."
  echo "Download it from: https://nodejs.org/ (LTS version)"
  echo "Or install it with a version manager, e.g.:"
  echo "  fnm: https://github.com/Schniz/fnm  (then: fnm install --lts)"
  echo "  nvm: https://github.com/nvm-sh/nvm  (then: nvm install --lts)"
  echo "Then re-run this script."
  read -r -p "Press Enter to close..." _
  exit 1
fi
NODE_MAJOR=$(node -p "process.versions.node.split('.')[0]")
if [ "$NODE_MAJOR" -lt 22 ]; then
  echo "ERROR: Node.js 22 or newer is required (found $(node --version))."
  echo "Download it from: https://nodejs.org/ (LTS version)"
  echo "Or install it with a version manager, e.g.:"
  echo "  fnm: https://github.com/Schniz/fnm  (then: fnm install --lts)"
  echo "  nvm: https://github.com/nvm-sh/nvm  (then: nvm install --lts)"
  echo "Then re-run this script."
  read -r -p "Press Enter to close..." _
  exit 1
fi
echo "Found node $(node --version)"

node scripts/project-setup.mjs

echo
echo "Adding the cvdesk command to your PATH..."
chmod +x bin/cvdesk
PROFILE="$HOME/.zshrc"
[ "$(basename "$SHELL")" = "bash" ] && PROFILE="$HOME/.bash_profile"
MARKER="# cmdtyView Desktop API TypeScript starter: cvdesk command"
# The copy of this project you last ran setup in wins: remove the PATH lines earlier setups
# added (for this or any other copy), then add this one at the end, where it comes first.
if [ -f "$PROFILE" ]; then
  CLEANED="$(awk -v marker="$MARKER" '
    skip { skip = 0; if (index($0, "export PATH=") == 1) next }
    $0 == marker { pending = 0; skip = 1; next }
    { if (pending) print ""; pending = 0 }
    $0 == "" { pending = 1; next }
    { print }
    END { if (pending) print "" }' "$PROFILE")"
  # Rewrite in place (not mv), so a profile that is a symlink stays one.
  printf '%s\n' "$CLEANED" > "$PROFILE"
fi
printf '\n%s\nexport PATH="%s/bin:$PATH"\n' "$MARKER" "$(pwd)" >> "$PROFILE"
echo "cvdesk now runs from $(pwd) (set in $PROFILE)"

echo
echo "Setup complete!"
echo "To run the starter guide, open a new terminal window and run:"
echo "  cvdesk start-guide"
echo "Put your own scripts in the my-scripts folder. To get the newest version"
echo "of this project later, run: cvdesk update"
read -r -p "Press Enter to close..." _
