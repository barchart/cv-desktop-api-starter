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

echo
mkdir -p my-scripts
if ! bash scripts/dependencies.sh; then
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
echo "  cvdesk StartGuide.java"
echo "Put your own scripts in the my-scripts folder. To get the newest version"
echo "of this project later, run: cvdesk update"
# Run by the setup.command at the top of the project, which pauses once at the end.
[ -n "$CVDESK_SETUP_FROM_TOP" ] || read -r -p "Press Enter to close..." _
