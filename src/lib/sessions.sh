# Session helpers
get_unique_sessions() {
    tmux list-sessions -F '#{session_name}' \
      | grep -v '^popout_' \
      | sed 's/^floating_//; s/_[0-9]*$//' \
      | sort -u
}

get_sessions_for_base() {
    base_name="$1"
    tmux list-sessions -F '#{session_name}' \
      | grep -v '^popout_' \
      | grep -E "^(floating_${base_name}_[0-9]*)|(${base_name})$"
}

list_sessions() {
    get_unique_sessions
}

kill_session() {
    base_name="$1"
    sessions_to_remove=$(get_sessions_for_base "${base_name}")
    echo "$sessions_to_remove"
    printf "%s\n" "${sessions_to_remove}" | while IFS= read -r session; do
      tmux kill-session -t "${session}" && printf "Removed session: %s\n" "${session}" >&2
    done
}

# Backward-compatible no-op hook for popup session setup.
configure_inner_tmux() {
    :
}

popup() {
    window_id=$(tmux display-message -p '#I')
    current_session_name=$(tmux display-message -p '#S')
    parent_session_dir=$(tmux display-message -p -F "#{pane_current_path}")
    session_name="floating_${current_session_name}_${window_id}"
    startup_command="$1"

    create_session() {
        if [ -z "$startup_command" ]; then
            tmux new-session -d -s "$session_name" -c "$parent_session_dir"
        else
            window_name=$(echo "$startup_command" | cut -d' ' -f1)
            tmux new-session -d -s "$session_name" -c "$parent_session_dir" "$startup_command"
            tmux rename-window -t "$session_name":1 "$window_name"
        fi
    }

    if tmux has-session -t "$session_name" 2>/dev/null; then
        if [ -n "$startup_command" ]; then
            target_pane=$(tmux list-panes -a -F "#{session_name} #{pane_id} #{window_name}" | grep -i "^$session_name" | grep -i "$(echo "$startup_command" | cut -d' ' -f1)" | awk '{print $2}')
            switch_command=""
            if [ -z "$target_pane" ]; then
                window_name=$(echo "$startup_command" | cut -d' ' -f1)
                tmux new-window -t "$session_name" -n "$window_name" -c "$parent_session_dir" "$startup_command"
            else
                switch_command="tmux select-window -t $(tmux display-message -p -F "#{window_index}" -t"$target_pane") ;"
            fi
        fi
        tmux popup -w 90% -h 80% -E "bash -c \"tmux attach -t $session_name; $switch_command\""
    else
        create_session
        configure_inner_tmux
        tmux popup -w 90% -h 80% -E "bash -c \"tmux attach -t $session_name\""
    fi
}
