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
go mod download

echo
echo "Setup complete!"
echo "To run the starter guide, open a terminal in the go folder and run:"
echo "  go run ./cmd/start-guide"
read -r -p "Press Enter to close..." _
