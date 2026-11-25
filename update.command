#!/usr/bin/env bash
# Updates every language folder of this project to its newest version from
# GitHub, downloading it once (see scripts/update.sh).
#   ./update.command                 the latest release
#   ./update.command --from <file>   a .zip or .tar.gz you downloaded yourself
exec bash "$(dirname "$0")/scripts/update.sh" "$@"
