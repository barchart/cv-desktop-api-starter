#!/usr/bin/env bash
set -e
cd "$(dirname "$0")"

echo "=== OpenFeed Python Starter Setup ==="
echo

# On macOS, /usr/bin/python3 exists as a placeholder even without Command Line Tools installed,
# so `command -v` alone isn't enough - actually invoke it to trigger/detect the CLT install prompt.
if ! command -v python3 >/dev/null 2>&1 || ! PYTHON_VERSION="$(python3 --version 2>/dev/null)"; then
  echo "ERROR: Python 3 is not installed."
  echo "On macOS you may see a popup asking to install 'Command Line Developer Tools' - if so,"
  echo "click Install, wait for it to finish, then re-run this script."
  echo "Otherwise, download Python from: https://www.python.org/downloads/"
  read -r -p "Press Enter to close..." _
  exit 1
fi
echo "Found $PYTHON_VERSION"

bash ../setup-env.sh

echo
echo "Creating virtual environment and installing dependencies..."
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip >/dev/null
pip install -q -r requirements.txt

echo
echo "Setup complete!"
echo "To run the starter guide, open a terminal in the python folder and run:"
echo "  source venv/bin/activate"
echo "  python3 src/start_guide.py"
read -r -p "Press Enter to close..." _
