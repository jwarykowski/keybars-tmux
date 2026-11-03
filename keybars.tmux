#!/usr/bin/env bash
# keybars-tmux: a window that rang its bell, or went quiet, sends an event to
# keybars Pro; moving to another window sends tmux.seen, which clears it.
# TPM runs this on load; without TPM, run-shell it from tmux.conf.

dir=$(cd "$(dirname "$0")" && pwd)

opt() {
  local v
  v=$(tmux show-option -gqv "$1")
  echo "${v:-$2}"
}

kp=$(opt @keybars-command keybars-pro)
silence=$(opt @keybars-silence 0)
# a hook index of our own, so other plugins' hooks stay
at=73

send() {
  echo "run-shell -b \"'$dir/scripts/send' '$kp' $1 '#{session_name}'\""
}

tmux set-hook -g "alert-bell[$at]" "$(send tmux.bell)"
tmux set-hook -g "session-window-changed[$at]" "$(send tmux.seen)"
tmux set-hook -g "client-session-changed[$at]" "$(send tmux.seen)"
if [ "$silence" -gt 0 ] 2>/dev/null; then
  tmux set-option -gw monitor-silence "$silence"
  tmux set-hook -g "alert-silence[$at]" "$(send tmux.quiet)"
else
  tmux set-hook -gu "alert-silence[$at]"
fi
