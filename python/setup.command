#!/usr/bin/env bash
set -e
cd "$(dirname "$0")"

echo "=== OpenFeed Python Starter Setup ==="
echo

install_help() {
  echo
  echo "Download Python from: https://www.python.org/downloads/"
  echo "Or install it with Homebrew: brew install python"
  echo "Then re-run this script."
  read -r -p "Press Enter to close..." _
  exit 1
}

# uv (https://docs.astral.sh/uv/) installs Python without admin rights. Its installer puts it in
# ~/.local/bin (~/.cargo/bin in older versions), which this terminal may not have on PATH yet.
find_uv() {
  command -v uv 2>/dev/null && return
  for uv in "$HOME/.local/bin/uv" "$HOME/.cargo/bin/uv"; do
    [ -x "$uv" ] && echo "$uv" && return
  done
  return 1
}

# A Python 3.11+ that uv installed, which isn't always on PATH.
# --system skips virtual environments, such as this project's own venv.
python_from_uv() {
  local uv found
  uv="$(find_uv)" || return 1
  found="$("$uv" python find --system '>=3.11' 2>/dev/null)" || return 1
  "$found" --version >/dev/null 2>&1 && echo "$found"
}

# Prefer the newest versioned interpreter (e.g. python3.14 from Homebrew or python.org) over the
# plain `python3`, which on macOS is often Apple's older /usr/bin/python3.
PYTHON=""
for minor in $(seq 30 -1 11); do
  for candidate in "python3.$minor" "/opt/homebrew/bin/python3.$minor" "/usr/local/bin/python3.$minor"; do
    if command -v "$candidate" >/dev/null 2>&1 && "$candidate" --version >/dev/null 2>&1; then
      PYTHON="$candidate"
      break 2
    fi
  done
done

[ -z "$PYTHON" ] && PYTHON="$(python_from_uv || true)"

if [ -z "$PYTHON" ]; then
  # On macOS, /usr/bin/python3 exists as a placeholder even without Command Line Tools installed,
  # so `command -v` alone isn't enough - actually invoke it to trigger/detect the CLT install prompt.
  if FOUND="$(python3 --version 2>/dev/null)"; then
    echo "This project needs Python 3.11 or newer (found $FOUND)."
  else
    echo "Python 3 is not installed."
    echo "On macOS you may see a popup asking to install 'Command Line Developer Tools' -"
    echo "you can close it; this project needs a newer Python than the one it installs."
  fi
  echo
  echo "Setup can install it for you with uv (https://docs.astral.sh/uv/), which installs"
  echo "Python into your home folder without admin rights. This downloads and runs uv's installer."
  read -r -p "Install uv and Python now? [y/N] " ANSWER
  [[ "$ANSWER" =~ ^[Yy] ]] || install_help

  if ! find_uv >/dev/null; then
    echo
    echo "Installing uv..."
    curl -LsSf https://astral.sh/uv/install.sh | sh || true
    find_uv >/dev/null || { echo "Installing uv failed."; install_help; }
  fi
  echo
  echo "Installing Python..."
  # Without a version, uv installs the one in .python-version.
  "$(find_uv)" python install || { echo "Installing Python with uv failed."; install_help; }
  PYTHON="$(python_from_uv || true)"
  [ -n "$PYTHON" ] || { echo "uv installed Python, but setup could not find it."; install_help; }
  echo
fi
echo "Found $("$PYTHON" --version) ($(command -v "$PYTHON"))"

if ! "$PYTHON" scripts/project_setup.py; then
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
echo "  cvdesk start_guide.py"
echo "Put your own scripts in the my-scripts folder. To get the newest version"
echo "of this project later, run: cvdesk update"
# Run by the setup.command at the top of the project, which pauses once at the end.
[ -n "$CVDESK_SETUP_FROM_TOP" ] || read -r -p "Press Enter to close..." _
