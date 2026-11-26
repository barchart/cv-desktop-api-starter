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
if [ -f ../scripts/add-to-path.sh ] && [ -f ../bin/cvdesk ]; then
  echo "Adding the cvdesk command to your PATH..."
  bash ../scripts/add-to-path.sh
else
  echo "To get the cvdesk command, update the whole project once with ../update.command,"
  echo "then run this setup again."
fi

echo
echo "Setup complete!"
echo "To run the starter guide, open a new terminal window and run:"
echo "  cvdesk start-guide.ts"
echo "Put your own scripts in the my-scripts folder. To get the newest version"
echo "of this project later, run: cvdesk update"
# Run by the setup.command at the top of the project, which pauses once at the end.
[ -n "$CVDESK_SETUP_FROM_TOP" ] || read -r -p "Press Enter to close..." _
