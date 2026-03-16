SCRIPT_DIR="$(cd "$(dirname "$BATS_TEST_DIRNAME")" && pwd)"

testmux() { tmux -L "$TEST_SESSION" -f /dev/null "$@"; }

setup() {
	TEST_SESSION="tmux-nav-$$-$BATS_TEST_NUMBER"
	export PATH="$SCRIPT_DIR/bin:$PATH"
	testmux kill-server 2>/dev/null || true
}

teardown() {
	testmux kill-server 2>/dev/null || true
}

start_session() {
	local panes=${1:-2}
	testmux new-session -d -s "$TEST_SESSION" -x 200 -y 50
	for ((i = 1; i < panes; i++)); do
		testmux split-window -h -t "$TEST_SESSION"
	done
	testmux select-layout -t "$TEST_SESSION" even-horizontal
	testmux select-pane -t "$TEST_SESSION.0"
}

start_nvim() {
	local pane=${1:-"$TEST_SESSION.0"}
	local listen=${2:-}
	if [ -n "$listen" ]; then
		testmux send-keys -t "$pane" "nvim --clean --listen $listen" Enter
	else
		testmux send-keys -t "$pane" 'nvim --clean' Enter
	fi
	wait_for_nvim "$pane"
}

wait_for_nvim() {
	local pane=${1:-"$TEST_SESSION.0"}
	local i
	for i in $(seq 1 50); do
		if [ "$(testmux display-message -t "$pane" -p '#{pane_current_command}')" = "nvim" ]; then
			return 0
		fi
		sleep 0.1
	done
	echo "Timed out waiting for nvim in pane $pane" >&2
	return 1
}

active_pane() {
	testmux display-message -t "$TEST_SESSION" -p '#{pane_index}'
}

navigate() {
	testmux run-shell -t "$TEST_SESSION" "tmux-navigate $1"
	sleep 0.05
}

nvim_winnr() {
	local pane=${1:-"$TEST_SESSION.0"}
	local sock
	sock=$(testmux display-message -t "$pane" -p '#{@nvim_socket}')
	[ -n "$sock" ] && [ -S "$sock" ] || return 1
	nvim --headless --server "$sock" --remote-expr "winnr()" 2>&1
}

nvim_vsplit() {
	local pane=${1:-"$TEST_SESSION.0"}
	local count=${2:-1}
	local sock
	sock=$(testmux display-message -t "$pane" -p '#{@nvim_socket}')
	if [ -z "$sock" ] || [ ! -S "$sock" ]; then
		navigate right
		navigate left
		sock=$(testmux display-message -t "$pane" -p '#{@nvim_socket}')
	fi
	for ((i = 0; i < count; i++)); do
		nvim --headless --server "$sock" --remote-expr "execute('vsplit')" >/dev/null 2>&1
	done
}
