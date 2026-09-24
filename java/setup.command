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
JAVA_VERSION_LINE="$(java -version 2>&1 | head -n 1)"
# Extract the major version, handling both "17.0.x" and legacy "1.8.x" formats
JAVA_RAW_VERSION=$(echo "$JAVA_VERSION_LINE" | sed -E 's/.*"([0-9]+)(\.([0-9]+))?.*"/\1.\3/')
JAVA_MAJOR="${JAVA_RAW_VERSION%%.*}"
if [ "$JAVA_MAJOR" = "1" ]; then
  JAVA_MAJOR="${JAVA_RAW_VERSION#*.}"
fi
if [ "$JAVA_MAJOR" -lt 17 ] 2>/dev/null; then
  echo "ERROR: $JAVA_VERSION_LINE found, but JDK 17 or newer is required."
  echo "Download it from: https://adoptium.net/"
  read -r -p "Press Enter to close..." _
  exit 1
fi
echo "Found $JAVA_VERSION_LINE"

bash ../setup-env.sh

echo
echo "Downloading dependencies and compiling the project (this may take a minute)..."
chmod +x mvnw
./mvnw -q compile

echo
echo "Setup complete!"
echo "To run the starter guide, open a terminal in the java folder and run:"
echo "  ./mvnw -q compile exec:java"
read -r -p "Press Enter to close..." _
