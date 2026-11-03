# keybars-tmux

A tmux plugin for [keybars Pro](https://keybars.app/pro/): a window that
rang its bell, or went quiet, lights a key, and moving to another window
clears it. Leave a long job in a background window and the keyboard tells
you when it wants you.

It sends three events to keybars Pro's alert rules, with the session's name
as the repository, so a rule can light something different for one
session:

- `tmux.bell`: a window rang its bell (a finished build, a prompt waiting)
- `tmux.quiet`: a window printed nothing for a while (off unless you set
  `@keybars-silence`)
- `tmux.seen`: you moved to another window or session

## requirements

- keybars Pro running, with its command installed: App settings, Command
  line, **Install the command-line tool**
- tmux 3.0 or later; Linux or macOS

## install

With [TPM](https://github.com/tmux-plugins/tpm), in `~/.tmux.conf`:

```tmux
set -g @plugin 'jwarykowski/keybars-tmux'
```

then `prefix` + `I`. Without TPM, clone it and add:

```tmux
run-shell ~/keybars-tmux/keybars.tmux
```

## rules

The plugin only sends events; rules decide what lights.
`scripts/rules` (in `~/.tmux/plugins/keybars-tmux` with TPM) adds two: the
top-right key pulses amber on a bell and breathes blue on a quiet window,
until you move. Change them on keybars Pro's Alerts page like any other
rule.

## options

| option | default | |
|---|---|---|
| `@keybars-silence` | `0` (off) | seconds without output before a window counts as quiet; sets tmux's `monitor-silence` for every window |
| `@keybars-command` | `keybars-pro` | the command, if tmux's `$PATH` doesn't have it |

Set them before the plugin loads, then reload tmux's config.

## development

`make check` runs shellcheck and the tests, which start a tmux server of
their own against a fake `keybars-pro`.

## licence

MIT
