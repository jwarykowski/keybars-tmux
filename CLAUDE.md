# keybars-tmux

A TPM plugin that sends tmux's bell and silence alerts to keybars Pro, and
tmux.seen when you move. README.md has the detail; this file is what to keep
in mind while working here.

## Commands

- `make check`: shellcheck, then the tests. `tests/plugin_test.sh` runs a
  tmux server of its own (`-L`, `-f /dev/null`) against a fake
  `keybars-pro`, so it never touches your sessions.

## Keep in mind

- `keybars.tmux` is what TPM runs. It adds hooks at index 73 of each hook
  array, so the user's and other plugins' hooks stay; keep it that way.
- Hooks call `scripts/send` with `run-shell -b`, so tmux never waits on
  keybars Pro.
- tmux 3.0+ (hook arrays); CI's Ubuntu has 3.4.

## Related repos (in ~/development)

- `keybars-pro`: the app and the `keybars-pro` command. A change to its CLI
  (`alert`, `rules add`) can break this.
- `keybars-shell`: the shell plugins, built the same way.
