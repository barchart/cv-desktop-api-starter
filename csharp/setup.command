#!/usr/bin/env bash
set -e
cd "$(dirname "$0")"

echo "=== OpenFeed C# Starter Setup ==="
echo

if ! command -v dotnet >/dev/null 2>&1; then
  echo "ERROR: .NET SDK (10 or newer) is not installed."
  echo "Download it from: https://dotnet.microsoft.com/download"
  echo "Then re-run this script."
  read -r -p "Press Enter to close..." _
  exit 1
fi
DOTNET_VERSION="$(dotnet --version)"
DOTNET_MAJOR="${DOTNET_VERSION%%.*}"
if [ "$DOTNET_MAJOR" -lt 10 ] 2>/dev/null; then
  echo "ERROR: .NET SDK $DOTNET_VERSION found, but 10 or newer is required."
  echo "Download the latest from: https://dotnet.microsoft.com/download"
  read -r -p "Press Enter to close..." _
  exit 1
fi
echo "Found dotnet $DOTNET_VERSION"

echo
echo "Downloading dependencies and building the starter guide..."
mkdir -p my-scripts
if ! dotnet build examples/start-guide.cs --verbosity quiet --nologo; then
  read -r -p "Press Enter to close..." _
  exit 1
fi

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
echo "  cvdesk start-guide.cs"
echo "Put your own scripts in the my-scripts folder. To get the newest version"
echo "of this project later, run: cvdesk update"
# Run by the setup.command at the top of the project, which pauses once at the end.
[ -n "$CVDESK_SETUP_FROM_TOP" ] || read -r -p "Press Enter to close..." _
