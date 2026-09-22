#!/usr/bin/env bash
# Shared helper: creates the repo-root .env file interactively.
# Called by each language's setup.command script (e.g. `bash ../setup-env.sh`).
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
cd "$SCRIPT_DIR"

ENV_FILE=".env"
ENV_EXAMPLE=".env.example"

if [ -f "$ENV_FILE" ]; then
  echo ".env already exists at repo root - leaving your credentials untouched."
  exit 0
fi

cp "$ENV_EXAMPLE" "$ENV_FILE"

echo
echo "Let's set up your OpenFeed credentials (saved to .env, never committed to git)."
read -r -p "OpenFeed username: " OF_USER
read -r -s -p "OpenFeed password: " OF_PASS
echo
read -r -p "OpenFeed WebSocket URL [ws://localhost:9000]: " OF_WS
OF_WS=${OF_WS:-ws://localhost:9000}

cat > "$ENV_FILE" <<EOF
OPENFEED_USERNAME=$OF_USER
OPENFEED_PASSWORD=$OF_PASS
OPENFEED_WS_URL=$OF_WS
EOF

echo "Saved credentials to .env"
