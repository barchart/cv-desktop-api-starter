#!/usr/bin/env bash
set -e
cd "$(dirname "$0")"

echo "=== OpenFeed Java Starter Setup ==="
echo

if ! command -v java >/dev/null 2>&1; then
  echo "ERROR: Java (JDK 17 or newer) is not installed."
  echo "Download it from: https://adoptium.net/"
  echo "Then re-run this script."
  read -r -p "Press Enter to close..." _
  exit 1
fi
echo "Found $(java -version 2>&1 | head -n 1)"

bash ../setup-env.sh

echo
echo "Downloading dependencies and building the project (this may take a minute)..."
chmod +x mvnw
./mvnw -q package

echo
echo "Setup complete!"
echo "To run the starter guide, open a terminal in the java folder and run:"
echo "  java -jar target/openfeed-client-1.0.0-jar-with-dependencies.jar"
read -r -p "Press Enter to close..." _
