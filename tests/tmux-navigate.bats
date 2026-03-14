#!/usr/bin/env bats

load helpers

@test "non-nvim pane: navigates to next pane" {
	start_session 2
	[ "$(active_pane)" = "0" ]

	navigate right
	[ "$(active_pane)" = "1" ]
}

@test "non-nvim pane: wraps around" {
	start_session 2
	testmux select-pane -t "$TEST_SESSION.1"

	navigate right
	[ "$(active_pane)" = "0" ]
}

@test "nvim pane: moves within splits" {
	start_session 2
	start_nvim "$TEST_SESSION.0"
	nvim_vsplit "$TEST_SESSION.0" 1

	navigate right
	[ "$(active_pane)" = "0" ]
}

@test "nvim pane: crosses to tmux at edge" {
	start_session 2
	start_nvim "$TEST_SESSION.0"

	navigate right
	[ "$(active_pane)" = "1" ]
}

@test "reposition: target nvim lands at correct edge" {
	start_session 2
	start_nvim "$TEST_SESSION.0"
	nvim_vsplit "$TEST_SESSION.0" 2

	# move nvim cursor to rightmost split
	local sock
	sock=$(testmux display-message -t "$TEST_SESSION.0" -p '#{@nvim_socket}')
	nvim --headless --server "$sock" --remote-expr "execute('999wincmd l')" >/dev/null 2>&1

	# switch to pane 1, then navigate left into nvim
	testmux select-pane -t "$TEST_SESSION.1"
	navigate left
	[ "$(active_pane)" = "0" ]

	# reposition should have sent 999wincmd l (opposite of left) — cursor at rightmost
	local sock winnr_before winnr_after
	sock=$(testmux display-message -t "$TEST_SESSION.0" -p '#{@nvim_socket}')
	winnr_before=$(nvim --headless --server "$sock" --remote-expr "winnr()" 2>&1)
	nvim --headless --server "$sock" --remote-expr "execute('wincmd l')" >/dev/null 2>&1
	winnr_after=$(nvim --headless --server "$sock" --remote-expr "winnr()" 2>&1)
	# if already at rightmost edge, wincmd l shouldn't change winnr
	[ "$winnr_before" = "$winnr_after" ]
}

@test "single pane: nvim wraps within splits" {
	start_session 1
	start_nvim "$TEST_SESSION.0"
	nvim_vsplit "$TEST_SESSION.0" 1

	# move to rightmost split
	local sock
	sock=$(testmux display-message -t "$TEST_SESSION.0" -p '#{@nvim_socket}')
	nvim --headless --server "$sock" --remote-expr "execute('999wincmd l')" >/dev/null 2>&1
	local before after
	before=$(nvim --headless --server "$sock" --remote-expr "winnr()" 2>&1)

	# navigate right at edge — should wrap to leftmost
	navigate right
	after=$(nvim --headless --server "$sock" --remote-expr "winnr()" 2>&1)
	[ "$before" != "$after" ]
}

# Known issue: pgrep -oP finds the oldest nvim child, which is the
# backgrounded (stopped) instance. The stopped nvim can't respond to RPC,
# so navigation hangs. This test confirms pgrep picks the wrong process.
@test "known issue: pgrep finds backgrounded nvim instead of foreground" {
	start_session 1
	start_nvim "$TEST_SESSION.0"

	# background nvim and start a fresh one
	testmux send-keys -t "$TEST_SESSION.0" C-z
	sleep 0.5
	start_nvim "$TEST_SESSION.0"

	local shell_pid bg_pid fg_pid found_pid
	shell_pid=$(testmux display-message -t "$TEST_SESSION.0" -p '#{pane_pid}')
	bg_pid=$(pgrep -oP "$shell_pid" nvim 2>/dev/null)
	fg_pid=$(pgrep -P "$shell_pid" nvim 2>/dev/null | tail -1)

	# the two instances should be different
	[ "$bg_pid" != "$fg_pid" ]

	# pgrep -oP (used by the script) returns the older, backgrounded one
	[ "$bg_pid" -lt "$fg_pid" ]

	# the backgrounded process is stopped
	case "$(ps -o state= -p "$bg_pid")" in T*) ;; *) return 1 ;; esac
}

@test "cache: socket is cached on pane option" {
	start_session 2
	start_nvim "$TEST_SESSION.0"

	navigate right
	navigate left

	cached=$(testmux display-message -t "$TEST_SESSION.0" -p '#{@nvim_socket}')
	[ -n "$cached" ]
	[ -S "$cached" ]
}
