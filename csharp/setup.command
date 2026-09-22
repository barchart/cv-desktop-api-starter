#!/usr/bin/env bash
set -e
cd "$(dirname "$0")"

echo "=== OpenFeed C# Starter Setup ==="
echo

if ! command -v dotnet >/dev/null 2>&1; then
  echo "ERROR: .NET SDK (10.0 or newer) is not installed."
  echo "Download it from: https://dotnet.microsoft.com/download"
  echo "Then re-run this script."
  read -r -p "Press Enter to close..." _
  exit 1
fi
echo "Found dotnet $(dotnet --version)"

bash ../setup-env.sh

echo
echo "Restoring dependencies..."
dotnet restore OpenFeedStartGuide/OpenFeedStartGuide.csproj

echo
echo "Setup complete!"
echo "To run the starter guide, open a terminal in the csharp/OpenFeedStartGuide folder and run:"
echo "  dotnet run"
read -r -p "Press Enter to close..." _
