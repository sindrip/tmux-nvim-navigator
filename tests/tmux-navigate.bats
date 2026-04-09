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

@test "backgrounded nvim: navigates with foreground instance" {
	start_session 2
	start_nvim "$TEST_SESSION.0"
	nvim_vsplit "$TEST_SESSION.0" 1

	# cross through both nvim splits to pane 1, then wrap back to pane 0
	navigate right
	navigate right
	[ "$(active_pane)" = "1" ]
	navigate right
	[ "$(active_pane)" = "0" ]

	# background nvim and start a fresh one (no vsplit)
	testmux send-keys -t "$TEST_SESSION.0" C-z
	sleep 0.5
	start_nvim "$TEST_SESSION.0"

	# right twice: new nvim has 1 window so first right crosses to pane 1,
	# second right wraps back to the nvim pane
	navigate right
	navigate right
	[ "$(active_pane)" = "0" ]
}

@test "nvim --listen: discovers custom socket name" {
	start_session 2
	start_nvim "$TEST_SESSION.0" "custom-sock"

	navigate right
	[ "$(active_pane)" = "1" ]

	navigate left
	[ "$(active_pane)" = "0" ]

	local sock
	sock=$(testmux display-message -t "$TEST_SESSION.0" -p '#{@nvim_socket}')
	[[ "$sock" == *custom-sock* ]]
}

@test "stale socket: navigation does not hang" {
	start_session 2
	start_nvim "$TEST_SESSION.0"

	# populate cache
	navigate right
	navigate left

	# kill nvim to make the cached socket stale
	testmux send-keys -t "$TEST_SESSION.0" ':qa!' Enter
	sleep 0.5

	# pane 0 is now a shell — navigating should still work
	navigate right
	[ "$(active_pane)" = "1" ]
}

@test "nvim restart: discovers new server socket" {
	start_session 2
	start_nvim "$TEST_SESSION.0"

	# populate cache
	navigate right
	[ "$(active_pane)" = "1" ]
	navigate left
	[ "$(active_pane)" = "0" ]

	local old_sock
	old_sock=$(testmux display-message -t "$TEST_SESSION.0" -p '#{@nvim_socket}')
	[ -n "$old_sock" ]

	# restart nvim — new server process, old cache is stale
	testmux send-keys -t "$TEST_SESSION.0" ':restart' Enter
	wait_for_nvim "$TEST_SESSION.0"
	sleep 1

	# clear stale cache
	testmux set-option -p -t "$TEST_SESSION.0" -u @nvim_socket 2>/dev/null || true
	testmux set-option -p -t "$TEST_SESSION.0" -u @nvim_pid 2>/dev/null || true

	# create splits in the new server and navigate through them
	nvim_vsplit "$TEST_SESSION.0" 1

	navigate right
	[ "$(active_pane)" = "0" ]
	navigate right
	[ "$(active_pane)" = "1" ]

	# cache should point to the new socket
	local new_sock
	new_sock=$(testmux display-message -t "$TEST_SESSION.0" -p '#{@nvim_socket}')
	[ -n "$new_sock" ]
	[ "$new_sock" != "$old_sock" ]
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
