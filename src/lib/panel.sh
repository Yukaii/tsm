panel_normalize_direction() {
    case "$1" in
        ""|bottom|down) echo "bottom" ;;
        left) echo "left" ;;
        right) echo "right" ;;
        *)
            echo "Error: Invalid direction '$1'. Use bottom, left, or right." >&2
            return 1
            ;;
    esac
}

panel_toggle() {
    local direction="bottom"
    local action="${1:-toggle}"
    shift || true

    if [ "$action" != "toggle" ]; then
        echo "Error: Unknown panel action '$action'. Use: tsm panel toggle [--direction ...]" >&2
        return 1
    fi

    while [ $# -gt 0 ]; do
        case "$1" in
            -d|--direction)
                if [ -z "${2:-}" ]; then
                    echo "Error: --direction requires a value (bottom|left|right)." >&2
                    return 1
                fi
                direction="$2"
                shift 2
                ;;
            --direction=*)
                direction="${1#*=}"
                shift
                ;;
            *)
                echo "Error: Unknown option '$1'. Use: tsm panel toggle [--direction ...]" >&2
                return 1
                ;;
        esac
    done

    direction=$(panel_normalize_direction "$direction") || return 1

    local current_pane
    current_pane="${TMUX_PANE:-}"
    if [ -z "$current_pane" ]; then
        current_pane=$(tmux display-message -p '#{pane_id}' 2>/dev/null || true)
    fi
    if [ -z "$current_pane" ]; then
        echo "Error: panel toggle must run inside tmux." >&2
        return 1
    fi

    local current_window_id
    local session_name
    local safe_session
    local store_session
    current_window_id=$(tmux display-message -p -t "$current_pane" '#{window_id}')
    session_name=$(tmux display-message -p -t "$current_pane" '#{session_name}')
    safe_session=$(printf '%s' "$session_name" | tr -c '[:alnum:]_-' '_')
    store_session="__tsm_panel_store_${safe_session}"

    local sig_value="v6"

    panel_clear_window_state() {
        tmux set-window-option -t "$current_window_id" -u @tsm_panel_id 2>/dev/null || true
        tmux set-window-option -t "$current_window_id" -u @tsm_panel_pid 2>/dev/null || true
        tmux set-window-option -t "$current_window_id" -u @tsm_panel_sig 2>/dev/null || true
        tmux set-window-option -t "$current_window_id" -u @tsm_panel_direction 2>/dev/null || true
        tmux set-window-option -t "$current_window_id" -u @tsm_panel_return_pane 2>/dev/null || true
    }

    panel_set_window_state() {
        local pane_id="$1"
        local pane_pid="$2"
        local pane_direction="$3"
        local return_pane="$4"
        tmux set-window-option -t "$current_window_id" @tsm_panel_id "$pane_id"
        tmux set-window-option -t "$current_window_id" @tsm_panel_pid "$pane_pid"
        tmux set-window-option -t "$current_window_id" @tsm_panel_sig "$sig_value"
        tmux set-window-option -t "$current_window_id" @tsm_panel_direction "$pane_direction"
        tmux set-window-option -t "$current_window_id" @tsm_panel_return_pane "$return_pane"
    }

    panel_clear_parked_state() {
        tmux set-option -t "$session_name" -u @tsm_panel_parked_id 2>/dev/null || true
        tmux set-option -t "$session_name" -u @tsm_panel_parked_pid 2>/dev/null || true
    }

    panel_set_parked_state() {
        local pane_id="$1"
        local pane_pid="$2"
        tmux set-option -t "$session_name" @tsm_panel_parked_id "$pane_id"
        tmux set-option -t "$session_name" @tsm_panel_parked_pid "$pane_pid"
    }

    panel_ensure_store_session() {
        if ! tmux has-session -t "$store_session" 2>/dev/null; then
            tmux new-session -d -s "$store_session" -n "__panel_store__"
        fi
    }

    local window_panel_id
    local window_panel_pid
    local window_panel_sig
    local window_panel_return_pane
    window_panel_id=$(tmux show-window-options -t "$current_window_id" -v @tsm_panel_id 2>/dev/null || true)
    window_panel_pid=$(tmux show-window-options -t "$current_window_id" -v @tsm_panel_pid 2>/dev/null || true)
    window_panel_sig=$(tmux show-window-options -t "$current_window_id" -v @tsm_panel_sig 2>/dev/null || true)
    window_panel_return_pane=$(tmux show-window-options -t "$current_window_id" -v @tsm_panel_return_pane 2>/dev/null || true)

    # Hide current panel (park it) when the tracked pane is still valid.
    if [ "$window_panel_sig" = "$sig_value" ] && [ -n "$window_panel_id" ] && [ -n "$window_panel_pid" ]; then
        local live_pid
        live_pid=$(tmux display-message -p -t "$window_panel_id" '#{pane_pid}' 2>/dev/null || true)
        if [ "$live_pid" = "$window_panel_pid" ]; then
            if [ "$current_pane" = "$window_panel_id" ] && [ -n "$window_panel_return_pane" ]; then
                if tmux list-panes -t "$current_window_id" -F '#{pane_id}' | grep -qx "$window_panel_return_pane"; then
                    tmux select-pane -t "$window_panel_return_pane" 2>/dev/null || true
                fi
            fi
            panel_ensure_store_session
            tmux break-pane -d -s "$window_panel_id" -t "${store_session}:"
            panel_set_parked_state "$window_panel_id" "$window_panel_pid"
            panel_clear_window_state
            return 0
        fi
    fi

    panel_clear_window_state

    local target_pane
    local parked_id
    local parked_pid
    target_pane="$current_pane"
    parked_id=$(tmux show-options -t "$session_name" -v @tsm_panel_parked_id 2>/dev/null || true)
    parked_pid=$(tmux show-options -t "$session_name" -v @tsm_panel_parked_pid 2>/dev/null || true)

    if [ -n "$parked_id" ] && [ -n "$parked_pid" ]; then
        local live_parked_pid
        live_parked_pid=$(tmux display-message -p -t "$parked_id" '#{pane_pid}' 2>/dev/null || true)
        if [ "$live_parked_pid" = "$parked_pid" ]; then
            case "$direction" in
                bottom)
                    if ! tmux join-pane -d -f -s "$parked_id" -t "$target_pane" -v -l 30%; then
                        tmux join-pane -d -s "$parked_id" -t "$target_pane" -v -l 30%
                    fi
                    ;;
                left)
                    if ! tmux join-pane -d -f -s "$parked_id" -t "$target_pane" -h -b -l 30%; then
                        tmux join-pane -d -s "$parked_id" -t "$target_pane" -h -b -l 30%
                    fi
                    ;;
                right)
                    if ! tmux join-pane -d -f -s "$parked_id" -t "$target_pane" -h -l 30%; then
                        tmux join-pane -d -s "$parked_id" -t "$target_pane" -h -l 30%
                    fi
                    ;;
            esac

            local attached_id
            attached_id=$(tmux list-panes -t "$current_window_id" -F '#{pane_id} #{pane_pid}' | awk -v pid="$parked_pid" '$2==pid {print $1; exit}')
            if [ -n "$attached_id" ]; then
                panel_set_window_state "$attached_id" "$parked_pid" "$direction" "$current_pane"
                tmux select-pane -t "$attached_id" 2>/dev/null || true
                panel_clear_parked_state
                return 0
            fi
        fi
    fi

    panel_clear_parked_state

    # No parked panel exists; create a new one with requested direction.
    local cwd
    local new_panel_id
    local new_panel_pid
    cwd=$(tmux display-message -p -t "$current_pane" '#{pane_current_path}')
    case "$direction" in
        bottom)
            if ! new_panel_id=$(tmux split-window -f -v -d -l 30% -c "$cwd" -P -F '#{pane_id}'); then
                new_panel_id=$(tmux split-window -v -d -l 30% -c "$cwd" -P -F '#{pane_id}')
            fi
            ;;
        left)
            if ! new_panel_id=$(tmux split-window -f -h -b -d -l 30% -c "$cwd" -P -F '#{pane_id}'); then
                new_panel_id=$(tmux split-window -h -b -d -l 30% -c "$cwd" -P -F '#{pane_id}')
            fi
            ;;
        right)
            if ! new_panel_id=$(tmux split-window -f -h -d -l 30% -c "$cwd" -P -F '#{pane_id}'); then
                new_panel_id=$(tmux split-window -h -d -l 30% -c "$cwd" -P -F '#{pane_id}')
            fi
            ;;
    esac
    new_panel_pid=$(tmux display-message -p -t "$new_panel_id" '#{pane_pid}')
    panel_set_window_state "$new_panel_id" "$new_panel_pid" "$direction" "$current_pane"
    tmux select-pane -t "$new_panel_id" 2>/dev/null || true
}
