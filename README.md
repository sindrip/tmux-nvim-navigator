# tmux-nvim-navigator

[![CI](https://github.com/sindrip/tmux-nvim-navigator/actions/workflows/ci.yml/badge.svg)](https://github.com/sindrip/tmux-nvim-navigator/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

Navigate between tmux panes and Neovim splits seamlessly — pure tmux, no Neovim plugins or config required.

<video src="https://sindrip.github.io/tmux-nvim-navigator/demo.mp4"></video>

[![demo](https://sindrip.github.io/tmux-nvim-navigator/demo.gif)](https://sindrip.github.io/tmux-nvim-navigator/demo.mp4)


## Features

- **Zero Neovim setup** — works with any Neovim config, including `--clean` and multiple `NVIM_APPNAME` configurations
- **Cursor repositioning** — when entering a Neovim pane, the cursor jumps to the nearest split on the side you came from
- **Handles backgrounded Neovim** — correctly navigates to the foreground instance, ignoring stopped processes

## Default keybindings

| Key | Direction |
|-----|-----------|
| `Ctrl-h` | Left |
| `Ctrl-j` | Down |
| `Ctrl-k` | Up |
| `Ctrl-l` | Right |

## Requirements

- tmux >= 3.0
- Neovim >= 0.8

## Installation

### TPM (recommended)

Add the plugin to your `tmux.conf`:

```tmux
set -g @plugin 'sindrip/tmux-nvim-navigator'
```

To customize the keybindings, set these options **before** the plugin line:

```tmux
set -g @tmux-nvim-navigator-left  'C-h'
set -g @tmux-nvim-navigator-down  'C-j'
set -g @tmux-nvim-navigator-up    'C-k'
set -g @tmux-nvim-navigator-right 'C-l'
```

### Manual

Add these to your `tmux.conf`:

```tmux
bind -n C-h run-shell "/path/to/bin/tmux-navigate left"
bind -n C-j run-shell "/path/to/bin/tmux-navigate down"
bind -n C-k run-shell "/path/to/bin/tmux-navigate up"
bind -n C-l run-shell "/path/to/bin/tmux-navigate right"
```

## How it works

When you navigate in a direction:

1. If the current pane is running Neovim, the plugin tries to move within Neovim's splits
2. If the cursor is already at the edge of Neovim's splits (or the pane isn't running Neovim), it moves to the next tmux pane
3. When entering a Neovim pane, the cursor is repositioned to the nearest split on the side you came from

All of this is handled entirely on the tmux side via Neovim's `--remote-expr` RPC interface over the Unix socket. Your Neovim config stays completely untouched.

## Comparison with alternatives

Most navigation plugins require coordinated configuration on both the tmux and Neovim sides. tmux-nvim-navigator works entirely from tmux.

| Plugin | Neovim plugin required? | tmux config required? |
|--------|:-----------------------:|:---------------------:|
| **tmux-nvim-navigator** | **No** | Yes |
| [vim-tmux-navigator](https://github.com/christoomey/vim-tmux-navigator) | Yes | Yes |
| [smart-splits.nvim](https://github.com/mrjones2014/smart-splits.nvim) | Yes | Yes |
| [nvim-tmux-navigation](https://github.com/alexghergh/nvim-tmux-navigation) | Yes | Yes |
