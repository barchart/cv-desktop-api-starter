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

echo
echo "Installing dependencies..."
npm install --no-fund --no-audit --loglevel=error

echo
echo "Adding the cvdesk command to your PATH..."
chmod +x bin/cvdesk
PROFILE="$HOME/.zshrc"
[ "$(basename "$SHELL")" = "bash" ] && PROFILE="$HOME/.bash_profile"
PATH_LINE="export PATH=\"$(pwd)/bin:\$PATH\""
if ! grep -qxF "$PATH_LINE" "$PROFILE" 2>/dev/null; then
  printf '\n# cmdtyView Desktop API TypeScript starter: cvdesk command\n%s\n' "$PATH_LINE" >> "$PROFILE"
  echo "Added $(pwd)/bin to your PATH in $PROFILE"
fi

echo
echo "Setup complete!"
echo "To run the starter guide, open a new terminal window and run:"
echo "  cvdesk start-guide"
read -r -p "Press Enter to close..." _
