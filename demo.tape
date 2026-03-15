# Run from project root:  vhs demo.tape
# Produces: demo.mp4

Output demo.mp4

Require tmux
Require nvim

Set Shell "bash"
Set FontSize 18
Set Width 1200
Set Height 600
Set Theme "Catppuccin Mocha"
Set WindowBar Colorful
Set TypingSpeed 1ms
Set Padding 10

# ── Hidden setup ──────────────────────────────────────────────

# Hide

Type `tmux -L demo kill-server 2>/dev/null; true`
Enter
Sleep 300ms

# Start an isolated tmux server with a clean config
Type `tmux -L demo -f demo.conf new-session -d -s demo -x 120 -y 26`
Enter
Sleep 500ms

# Bind navigation keys using the plugin
Type `BIN="$(pwd)/bin/tmux-navigate"`
Enter
Type `tmux -L demo bind -n C-h run-shell "$BIN left" \; bind -n C-j run-shell "$BIN down" \; bind -n C-k run-shell "$BIN up" \; bind -n C-l run-shell "$BIN right"`
Enter
Sleep 200ms

# Create layout: two horizontal panes
Type `tmux -L demo split-window -h -t demo \; select-pane -t demo.0`
Enter
Sleep 300ms

# Open nvim with a project file in the left pane
Type `tmux -L demo send-keys -t demo.0 'nvim --clean README.md' Enter`
Enter
Sleep 1500ms

# Create a vertical split inside nvim
Type `tmux -L demo send-keys -t demo.0 ':vsplit LICENSE' Enter`
Enter
Sleep 500ms

# Attach to the session
Type `TMUX= tmux -L demo attach -t demo`
Enter
Sleep 800ms

# ── Visible demo ──────────────────────────────────────────────

# Show

Sleep 1.5

# 1. Move right: left nvim split → right nvim split
Ctrl+l
Sleep 1.2

# 2. Move right: right nvim split → tmux shell pane (crosses boundary)
Ctrl+l
Sleep 1.2

# 3. Move left: tmux shell pane → nvim (cursor repositioned to nearest split)
Ctrl+h
Sleep 1.2

# 4. Move left: right nvim split → left nvim split
Ctrl+h
Sleep 1.2

Sleep 1
