#!/usr/bin/env bash
# Shared helper: manages the repo-root .env and syncs a copy into the calling
# language folder, so each app can just read ".env" from its own working
# directory - no cross-directory searching needed.
# Called by each language's setup.command script from within its own folder
# (e.g. `bash ../setup-env.sh`).
set -e

CALLER_DIR="$(pwd)"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
cd "$SCRIPT_DIR"

ENV_FILE=".env"
ENV_EXAMPLE=".env.example"

if [ -f "$ENV_FILE" ]; then
  read -r -p "Credentials already exist. Set fresh OpenFeed credentials? [y/N]: " REFRESH
else
  REFRESH="y"
  cp "$ENV_EXAMPLE" "$ENV_FILE"
fi

case "$REFRESH" in
  [yY]*)
    echo
    echo "Let's set up your OpenFeed credentials (saved to .env, never committed to git)."
    read -r -p "OpenFeed username: " OF_USER
    read -r -s -p "OpenFeed password: " OF_PASS
    echo
    read -r -p "Desktop API port [9000]: " OF_PORT
    OF_PORT=${OF_PORT:-9000}

    cat > "$ENV_FILE" <<EOF
OPENFEED_USERNAME=$OF_USER
OPENFEED_PASSWORD=$OF_PASS
OPENFEED_WS_URL=ws://localhost:$OF_PORT
EOF
    echo "Saved credentials to .env"
    ;;
  *)
    echo "Keeping existing credentials in .env."
    ;;
esac

cp "$ENV_FILE" "$CALLER_DIR/.env"
echo "Synced credentials to $CALLER_DIR/.env"

