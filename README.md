# tmux-nvim-navigator

Navigate between tmux panes and Neovim splits seamlessly — pure tmux, no Neovim plugins or config required.

## How it works

When you navigate in a direction:

1. If the current pane is running Neovim, the plugin tries to move within Neovim's splits
2. If the cursor is already at the edge of Neovim's splits (or the pane isn't running Neovim), it moves to the next tmux pane
3. When entering a Neovim pane, the cursor is repositioned to the nearest split on the side you came from

All of this is handled entirely on the tmux side by communicating with Neovim over its RPC socket. Your Neovim config stays completely untouched — no plugins, no keybindings, no setup. This means it works with any Neovim configuration, including multiple configs via `NVIM_APPNAME`.

## Requirements

- tmux >= 3.0
- Neovim >= 0.8

## Keybindings

Add these to your `tmux.conf`:

```tmux
bind -n C-h run-shell "/path/to/bin/tmux-navigate left"
bind -n C-j run-shell "/path/to/bin/tmux-navigate down"
bind -n C-k run-shell "/path/to/bin/tmux-navigate up"
bind -n C-l run-shell "/path/to/bin/tmux-navigate right"
```
