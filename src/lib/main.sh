main() {
  case "$1" in
  list)
    if [ "$2" = "--help" ] || [ "$2" = "-h" ]; then
      display_help "list"
    else
      list_sessions
    fi
    ;;
  kill)
    if [ "$2" = "--help" ] || [ "$2" = "-h" ]; then
      display_help "kill"
    elif [ -z "$2" ]; then
      echo "Error: No session name provided for kill command. Use 'tsm help kill' for usage information." >&2
      exit 1
    else
      kill_session "$2"
    fi
    ;;
  popup)
    if [ "$2" = "--help" ] || [ "$2" = "-h" ]; then
      display_help "popup"
    else
      shift
      popup "$@"
    fi
    ;;
  panel)
    if [ "$2" = "--help" ] || [ "$2" = "-h" ]; then
      display_help "panel"
    else
      shift
      panel_toggle "$@"
    fi
    ;;
  move-window)
    if [ "$2" = "--help" ] || [ "$2" = "-h" ]; then
      display_help "move-window"
    else
      move_window
    fi
    ;;
  worktree | wt)
    if ! is_git_repo; then
      echo "Error: not inside a git repository." >&2
      exit 1
    fi

    echo "DEBUG: tsm worktree starting in $(pwd)" >>/tmp/tsm_error.log
    echo "DEBUG: TMUX=$TMUX" >>/tmp/tsm_error.log

    local local_root
    local main_root
    local all_flag
    local subcommand
    local_root=$(repo_root)
    main_root=$(main_repo_root)
    subcommand="$2"
    all_flag="false"

    for arg in "$@"; do
      case "$arg" in
      --all) all_flag="true" ;;
      esac
    done

    case "$subcommand" in
    "" | "--all")
      selection=$(worktree_select_interactive "$main_root")
      if [ -n "$TSM_DEBUG" ]; then
        echo "DEBUG: selection='$selection'" >&2
      fi
      if [ -z "$selection" ]; then
        exit 0
      fi

      local lines=()
      local i
      while IFS= read -r i; do
        lines+=("${i//$'\r'/}")
      done <<<"$selection"

      if [ -n "$TSM_DEBUG" ]; then
        echo "DEBUG: lines count=${#lines[@]}" >&2
        for idx in "${!lines[@]}"; do
          echo "DEBUG: lines[$idx]='${lines[$idx]}'" >&2
        done
      fi

      local selected_line=""
      if [ "${#lines[@]}" -eq 1 ]; then
        selected_line="${lines[0]}"
      elif [ "${#lines[@]}" -eq 2 ]; then
        selected_line="${lines[1]}"
      elif [ "${#lines[@]}" -ge 3 ]; then
        if [ "${lines[1]}" = "enter" ] && [ -n "${lines[2]}" ]; then
          selected_line="${lines[2]}"
        elif [ "${lines[1]}" = "enter" ]; then
          selected_line="${lines[0]}"
        else
          selected_line="${lines[1]}"
        fi
      fi

      if [ -n "$TSM_DEBUG" ]; then
        echo "DEBUG: selected_line='$selected_line'" >&2
      fi

      if [ -z "$selected_line" ]; then
        exit 0
      fi

      local branch path status
      branch=$(printf "%s" "$selected_line" | cut -f1)
      path=$(printf "%s" "$selected_line" | cut -f2)
      status=$(printf "%s" "$selected_line" | cut -f3)

      if [ -n "$TSM_DEBUG" ]; then
        echo "DEBUG: branch='$branch' path='$path' status='$status'" >&2
      fi

      if [ -z "$branch" ]; then
        exit 0
      fi

      if [ "$status" = "HAS_WORKTREE" ] && [ -n "$path" ] && [ "$path" != "CREATE_NEW" ]; then
        switch_to_worktree_session "$main_root" "$path"
      else
        worktree_create "$main_root" "$branch"
      fi
      ;;
    list)
      if [ "$all_flag" = "true" ]; then
        print_worktree_list_all
      else
        print_worktree_list_current "$local_root"
      fi
      ;;
    create)
      worktree_create "$local_root" "$3"
      ;;
    next)
      worktree_cycle "$local_root" "next"
      ;;
    prev)
      worktree_cycle "$local_root" "prev"
      ;;
    delete | remove | rm)
      worktree_delete "$local_root"
      ;;
    prune)
      worktree_prune
      ;;
    path)
      worktree_path_cmd "$local_root" "$3"
      ;;
    --help | -h)
      display_help "worktree"
      ;;
    *)
      echo "Error: Unknown worktree command '$subcommand'. Use 'tsm help worktree' for usage information." >&2
      exit 1
      ;;
    esac
    ;;
  help)
    display_help "$2"
    ;;
  --help | -h)
    display_help
    ;;
  "")
    display_help
    ;;
  *)
    echo "Error: Unknown command '$1'. Use 'tsm help' for usage information." >&2
    exit 1
    ;;
  esac
}
