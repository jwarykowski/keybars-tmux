#!/bin/sh
# ok and FAIL lines never fail
# shellcheck disable=SC2015
# keybars-tmux in a real tmux server of its own, against a fake keybars-pro
# that logs its arguments.
set -eu

tmp=$(mktemp -d)
root=$(cd "$(dirname "$0")/.." && pwd)
sock="keybars-test-$$"
T() { tmux -L "$sock" -f /dev/null "$@"; }
trap 'T kill-server 2>/dev/null || true; rm -rf "$tmp"' EXIT
log="$tmp/keybars.log"
kp="$tmp/keybars-pro"
printf '#!/bin/sh\necho "$*" >>"%s"\n' "$log" >"$kp"
chmod +x "$kp"

fails=0
check() {
  i=0
  while [ "$i" -lt 50 ] && ! grep -qxF -- "$2" "$log" 2>/dev/null; do
    sleep 0.1
    i=$((i + 1))
  done
  if grep -qxF -- "$2" "$log" 2>/dev/null; then
    echo "ok: $1"
  else
    echo "FAIL: $1: want \"$2\", got: $(cat "$log" 2>/dev/null)" >&2
    fails=$((fails + 1))
  fi
  : >"$log"
}

T new-session -d -s shop -x 80 -y 24
T new-window -d -t shop
T set-option -g @keybars-command "$kp"
T set-option -g @keybars-silence 1
T run-shell "$root/keybars.tmux"
T set-hook -g "alert-bell[1]" "set-option -g @mine yes"
sleep 0.5

T send-keys -t shop:1 "printf '\\a'" Enter
check "a bell" "alert -q -repo shop tmux.bell"
[ "$(T show-option -gqv @mine)" = yes ] && echo "ok: other bell hooks stay" || {
  echo "FAIL: our hook replaced another" >&2
  fails=$((fails + 1))
}
T select-window -t shop:1
check "moving to it" "alert -q -repo shop tmux.seen"
sleep 1.5
check "a quiet window" "alert -q -repo shop tmux.quiet"

T set-option -g @keybars-silence 0
T run-shell "$root/keybars.tmux"
[ -z "$(T show-hooks -g alert-silence 2>/dev/null | grep keybars || true)" ] && echo "ok: silence off" || {
  echo "FAIL: silence hook still there" >&2
  fails=$((fails + 1))
}

[ "$fails" -eq 0 ] || {
  echo "$fails failed" >&2
  exit 1
}
