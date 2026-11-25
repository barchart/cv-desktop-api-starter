#!/usr/bin/env bash
# Gets the newest version of this project from GitHub (see scripts/update.sh).
#   ./update.command                 the latest release
#   ./update.command --from <file>   a .zip or .tar.gz you downloaded yourself
exec bash "$(dirname "$0")/scripts/update.sh" "$@"
