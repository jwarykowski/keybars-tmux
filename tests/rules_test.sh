#!/bin/sh
# scripts/rules adds its two rules once.
set -eu

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
root=$(cd "$(dirname "$0")/.." && pwd)
export KEYBARS_PRO="$tmp/keybars-pro"
cat >"$KEYBARS_PRO" <<FAKE
#!/bin/sh
echo "\$*" >>"$tmp/log"
if [ "\$1 \$2" = "rules list" ]; then cat "$tmp/rules" 2>/dev/null || true; fi
if [ "\$1 \$2" = "rules add" ]; then echo "\$3" >>"$tmp/rules"; fi
FAKE
chmod +x "$KEYBARS_PRO"

fails=0
"$root/scripts/rules" >/dev/null
"$root/scripts/rules" >/dev/null
if [ "$(grep -c "rules add" "$tmp/log")" -eq 2 ]; then echo "ok: adds two, once"; else
  echo "FAIL: $(cat "$tmp/log")" >&2
  fails=1
fi
if grep -qxF "rules add tmux bell tmux.bell -keys top-right -colour amber -effect pulse -until -clear-on tmux.seen" "$tmp/log"; then
  echo "ok: the bell rule"
else
  echo "FAIL: no bell rule" >&2
  fails=1
fi
exit "$fails"
