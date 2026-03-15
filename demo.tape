# Run from project root:  vhs demo.tape

Output demo.mp4
Output demo.gif

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

Hide

Type `tmux -L demo kill-server 2>/dev/null; true`
Enter
Sleep 300ms

Type `tmux -L demo -f demo.conf new-session -d -s demo -x 120 -y 26`
Enter
Sleep 500ms

Type `BIN="$(pwd)/bin/tmux-navigate"`
Enter
Type `tmux -L demo bind -n C-h run-shell "$BIN left"`
Enter
Type `tmux -L demo bind -n C-j run-shell "$BIN down"`
Enter
Type `tmux -L demo bind -n C-k run-shell "$BIN up"`
Enter
Type `tmux -L demo bind -n C-l run-shell "$BIN right"`
Enter
# Bind arrow keys for speed burst (VHS @repeat only works on named keys)
Type `tmux -L demo bind -n Left run-shell "$BIN left"`
Enter
Type `tmux -L demo bind -n Right run-shell "$BIN right"`
Enter
Sleep 200ms

Type `TMUX= tmux -L demo attach -t demo`
Enter
Sleep 800ms

Show

# ── Act 1: Setup ─────────────────────────────────────────────

Sleep 1.5

# Split tmux — two shells side by side
Ctrl+b
Sleep 100ms
Type `%`
Sleep 1

# Cursor is in right pane — navigate back to left pane
Ctrl+h
Sleep 0.8

# Open nvim with zero config
Set TypingSpeed 60ms
Type "nvim --clean"
Set TypingSpeed 1ms
Sleep 500ms
Enter
Sleep 800ms

# Show what --clean means
Set TypingSpeed 60ms
Type ":h --clean"
Set TypingSpeed 1ms
Sleep 300ms
Enter
Sleep 1

# ── Act 2: Basic switching ───────────────────────────────────

# nvim → shell
Ctrl+l
Sleep 1.2

# shell → nvim (help stays open)
Ctrl+h
Sleep 1.2

# ── Act 3: Splits + wrapping ────────────────────────────────

# Add a vertical split inside nvim (3 nvim windows total)
Set TypingSpeed 60ms
Type ":vsplit"
Set TypingSpeed 1ms
Sleep 300ms
Enter
Sleep 800ms

# Cycle: nvim window → nvim window → shell → wraps back to nvim
Ctrl+l
Sleep 1.2

Ctrl+l
Sleep 1.2

Ctrl+l
Sleep 1.2

# ── Act 4: Speed burst ──────────────────────────────────────

# Rapid cycling right through all panes (~1s)
Right@30ms 9

Sleep 1000ms

# Rapid cycling left through all panes (~1s)
Left@30ms 9

# ── Reset for gif loop ───────────────────────────────────────

Sleep 500ms
Escape
Escape
Sleep 300ms
Set TypingSpeed 60ms
Type ":qa!"
Set TypingSpeed 1ms
Sleep 300ms
Enter
Sleep 1

Sleep 1.5
