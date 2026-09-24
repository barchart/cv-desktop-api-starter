#!/usr/bin/env bash
set -e
cd "$(dirname "$0")"

echo "=== OpenFeed C# Starter Setup ==="
echo

if ! command -v dotnet >/dev/null 2>&1; then
  echo "ERROR: .NET SDK (8.0 or newer) is not installed."
  echo "Download it from: https://dotnet.microsoft.com/download"
  echo "Then re-run this script."
  read -r -p "Press Enter to close..." _
  exit 1
fi
DOTNET_VERSION="$(dotnet --version)"
DOTNET_MAJOR="${DOTNET_VERSION%%.*}"
if [ "$DOTNET_MAJOR" -lt 8 ] 2>/dev/null; then
  echo "ERROR: .NET SDK $DOTNET_VERSION found, but 8.0 or newer is required."
  echo "Download the latest from: https://dotnet.microsoft.com/download"
  read -r -p "Press Enter to close..." _
  exit 1
fi
echo "Found dotnet $DOTNET_VERSION"

bash ../setup-env.sh

echo
echo "Restoring dependencies..."
dotnet restore OpenFeedStartGuide/OpenFeedStartGuide.csproj

echo
echo "Setup complete!"
echo "To run the starter guide, open a terminal in the csharp folder and run:"
echo "  dotnet run --project OpenFeedStartGuide"
read -r -p "Press Enter to close..." _
