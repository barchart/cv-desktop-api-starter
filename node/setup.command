#!/usr/bin/env bash
set -e
cd "$(dirname "$0")"

echo "=== OpenFeed Node.js Starter Setup ==="
echo

if ! command -v node >/dev/null 2>&1; then
  echo "ERROR: Node.js is not installed."
  echo "Download it from: https://nodejs.org/ (LTS version)"
  echo "Then re-run this script."
  read -r -p "Press Enter to close..." _
  exit 1
fi
echo "Found node $(node --version)"

bash ../setup-env.sh

echo
echo "Installing dependencies..."
npm install

echo
echo "Setup complete!"
echo "To run the starter guide, open a terminal in the node folder and run:"
echo "  npm start"
read -r -p "Press Enter to close..." _
