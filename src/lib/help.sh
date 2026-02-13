display_help() {
  local command="$1"
  case "$command" in
  "")
    cat <<EOF
Usage: tsm <command> [options]

Tmux Session Manager (tsm) - Manage tmux sessions efficiently

Commands:
  list                List all unique session names
  kill <session>      Kill all sessions with the given base name
  popup [command]     Create or attach to a floating popup session
  panel               Toggle persistent panel (supports direction)
  move-window         Move current window to another session (fzf picker)
  worktree|wt         Manage git worktrees for the current repo
  help [command]      Display help information for tsm or a specific command

Use "tsm help <command>" for more information about a specific command.
EOF
    ;;
  "list")
    cat <<EOF
Usage: tsm list

List all unique tmux session names.

This command displays a list of all unique session names, removing any
"floating_" prefixes and numeric suffixes for easier readability.

Example:
  $ tsm list
EOF
    ;;
  "kill")
    cat <<EOF
Usage: tsm kill <session_name>

Kill all tmux sessions with the given base name.

This command will terminate all sessions that match the provided name,
including both regular and floating sessions.

Arguments:
  <session_name>    The base name of the session(s) to kill

Example:
  $ tsm kill mysession
EOF
    ;;
  "popup")
    cat <<EOF
Usage: tsm popup [command]

Create or attach to a floating popup tmux session.

If no command is provided, a new shell will be opened in the floating session.
If the floating session already exists, the script will attach to it.
If a command is provided and the process is already running in the session,
the script will switch to the corresponding window.

Arguments:
  [command]    Optional command to run in the new session

Examples:
  $ tsm popup
  $ tsm popup "vim myfile.txt"
EOF
    ;;
  "worktree")
    cat <<EOF
Usage: tsm worktree [--all]
       tsm worktree list [--all]
       tsm worktree next
       tsm worktree prev
       tsm worktree delete
       tsm worktree prune
       tsm worktree path <branch>

Manage git worktrees for the current repository.

Commands:
  (default)           Unified picker: switch to existing worktree or create new
                      - Shows existing worktrees (switch)
                      - Shows branches without worktrees (create)
                      - Type new branch name (create)
  list                Print worktrees (no switch)
  next                Cycle to the next worktree session
  prev                Cycle to the previous worktree session
  delete              Remove a worktree
  prune               Prune stale git worktree metadata
  path <branch>       Print the canonical worktree path for <branch>

Options:
  --all               Include all tracked worktrees under ${WORKTREE_ROOT}
EOF
    ;;
  "panel")
    cat <<EOF
Usage: tsm panel toggle [--direction <bottom|left|right>]

Toggle a persistent tmux panel for the current tmux session.

Behavior:
  - If panel is open in current window: park it in a hidden store session
  - If panel is parked: restore it into current window
  - If no parked panel exists: create a new one

Options:
  --direction, -d     Panel placement: bottom (default), left, right

Examples:
  $ tsm panel toggle
  $ tsm panel toggle --direction left
  $ tsm panel toggle -d right
EOF
    ;;
  "move-window")
    cat <<EOF
Usage: tsm move-window

Move the current tmux window to another session using an interactive fzf picker.

This command displays all available sessions (excluding the current one) in a
fuzzy finder. Select a target session and the current window will be moved there.
Press Esc to cancel without moving.

Example:
  $ tsm move-window
EOF
    ;;
  *)
    echo "Error: Unknown command '$command'. Use 'tsm help' for general usage information."
    exit 1
    ;;
  esac
}
