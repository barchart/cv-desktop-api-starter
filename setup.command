#!/usr/bin/env bash
# Asks which languages to set up, then runs each one's own setup
# (<language>/setup.command, which also works on its own).
cd "$(dirname "$0")" || exit 1

echo "=== cmdtyView Desktop API Starter Setup ==="
echo
echo "Which language do you want to set up?"
echo "  1) TypeScript"
echo "  2) Python"
echo "  3) Java"
echo "  4) Go"
echo "  5) C#"
echo
read -r -p "Type a number (or several, like: 1 2) and press Enter: " ANSWER

FOLDERS=""
for choice in ${ANSWER//,/ }; do
  case "$(printf '%s' "$choice" | tr 'A-Z' 'a-z')" in
    1 | typescript | ts) folder=typescript ;;
    2 | python | py) folder=python ;;
    3 | java) folder=java ;;
    4 | go) folder=go ;;
    5 | csharp | cs | "c#") folder=csharp ;;
    *)
      echo "\"$choice\" isn't one of the choices. Run this again and type a number from 1 to 5."
      read -r -p "Press Enter to close..." _
      exit 1 ;;
  esac
  case " $FOLDERS " in *" $folder "*) ;; *) FOLDERS="$FOLDERS $folder" ;; esac
done
if [ -z "$FOLDERS" ]; then
  echo "Nothing chosen. Run this again and type a number from 1 to 5."
  read -r -p "Press Enter to close..." _
  exit 1
fi

DONE=""
FAILED=""
for folder in $FOLDERS; do
  echo
  if CVDESK_SETUP_FROM_TOP=1 bash "$folder/setup.command"; then
    DONE="$DONE $folder"
  else
    FAILED="$FAILED $folder"
  fi
done

echo
echo "=== Done ==="
[ -z "$DONE" ] || echo "Set up:$DONE"
[ -z "$FAILED" ] || echo "Not set up:$FAILED (see above, fix it, then run this again)"
read -r -p "Press Enter to close..." _
[ -z "$FAILED" ]
