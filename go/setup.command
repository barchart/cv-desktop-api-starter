#!/usr/bin/env bash
set -e
cd "$(dirname "$0")"

echo "=== OpenFeed Go Starter Setup ==="
echo

if ! command -v go >/dev/null 2>&1; then
  echo "ERROR: Go is not installed."
  echo "Download it from: https://go.dev/dl/"
  echo "Then re-run this script."
  read -r -p "Press Enter to close..." _
  exit 1
fi
echo "Found $(go version)"

echo
echo "Downloading dependencies..."
mkdir -p my-scripts
go mod download

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
echo "  cvdesk start-guide.go"
echo "Put your own scripts in the my-scripts folder. To get the newest version"
echo "of this project later, run: cvdesk update"
# Run by the setup.command at the top of the project, which pauses once at the end.
[ -n "$CVDESK_SETUP_FROM_TOP" ] || read -r -p "Press Enter to close..." _
