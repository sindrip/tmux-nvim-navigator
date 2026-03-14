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
	nvim --server "$sock" --remote-expr "luaeval('vim.cmd(\"999wincmd l\")')" >/dev/null 2>&1

	# switch to pane 1, then navigate left into nvim
	testmux select-pane -t "$TEST_SESSION.1"
	navigate left
	[ "$(active_pane)" = "0" ]

	# reposition should have sent 999wincmd l (opposite of left) — cursor at rightmost
	local sock winnr_before winnr_after
	sock=$(testmux display-message -t "$TEST_SESSION.0" -p '#{@nvim_socket}')
	winnr_before=$(nvim --server "$sock" --remote-expr "winnr()" 2>/dev/null)
	nvim --server "$sock" --remote-expr "luaeval('vim.cmd(\"wincmd l\")')" >/dev/null 2>&1
	winnr_after=$(nvim --server "$sock" --remote-expr "winnr()" 2>/dev/null)
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
	nvim --server "$sock" --remote-expr "luaeval('vim.cmd(\"999wincmd l\")')" >/dev/null 2>&1
	local before after
	before=$(nvim --server "$sock" --remote-expr "winnr()" 2>/dev/null)

	# navigate right at edge — should wrap to leftmost
	navigate right
	after=$(nvim --server "$sock" --remote-expr "winnr()" 2>/dev/null)
	echo "sock=$sock before=$before after=$after" >&2
	echo "pane_cmd=$(testmux display-message -t "$TEST_SESSION.0" -p '#{pane_current_command}')" >&2
	echo "cached=$(testmux display-message -t "$TEST_SESSION.0" -p '#{@nvim_socket}')" >&2
	[ "$before" != "$after" ]
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
