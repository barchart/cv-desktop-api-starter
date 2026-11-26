#!/usr/bin/env bash
# Copies the libraries pom.xml lists into lib/, where cvdesk puts them on the
# classpath (and where VS Code's Java support finds them). Run by setup.command,
# and by cvdesk whenever pom.xml has changed since (after an update).
#   dependencies.sh               always
#   dependencies.sh --if-needed   only if pom.xml changed since the last time
# Messages go to stderr, so a script's own output stays clean.
cd "$(dirname "$0")/.." || exit 1
if [ "$1" = "--if-needed" ] && cmp -s pom.xml lib/.pom.xml; then
  exit 0
fi
echo "Downloading the Java libraries (this may take a minute)..." >&2
rm -rf lib
chmod +x mvnw
if ! ./mvnw -q dependency:copy-dependencies -DoutputDirectory=lib >&2; then
  echo "Downloading the Java libraries failed." >&2
  exit 1
fi
cp pom.xml lib/.pom.xml
