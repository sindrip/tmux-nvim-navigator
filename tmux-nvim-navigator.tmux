#!/usr/bin/env bash

get_option() {
    local value
    value=$(tmux show-options -gvq "$1")
    echo "${value:-$2}"
}

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

left_key=$(get_option  '@tmux-nvim-navigator-left'  'C-h')
down_key=$(get_option  '@tmux-nvim-navigator-down'  'C-j')
up_key=$(get_option    '@tmux-nvim-navigator-up'    'C-k')
right_key=$(get_option '@tmux-nvim-navigator-right' 'C-l')

tmux bind-key -n "$left_key"  run-shell "$CURRENT_DIR/bin/tmux-navigate left"
tmux bind-key -n "$down_key"  run-shell "$CURRENT_DIR/bin/tmux-navigate down"
tmux bind-key -n "$up_key"    run-shell "$CURRENT_DIR/bin/tmux-navigate up"
tmux bind-key -n "$right_key" run-shell "$CURRENT_DIR/bin/tmux-navigate right"
