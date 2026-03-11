#!/bin/bash

TMUX_SESSION_NAME="codex"

show_banner() {
    clear
    echo "==============================================="
    echo "               Codex Terminal"
    echo "           Interactive Session Picker"
    echo "==============================================="
    echo ""
}

check_existing_session() {
    tmux has-session -t "$TMUX_SESSION_NAME" 2>/dev/null
}

show_menu() {
    echo "Choose your Codex session type:"
    echo ""

    if check_existing_session; then
        echo "  0) Reconnect to existing session (recommended)"
        echo ""
    fi

    echo "  1) New interactive Codex session (default)"
    echo "  2) Custom Codex command"
    echo "  3) Login help"
    echo "  4) Drop to bash shell"
    echo "  5) Exit"
    echo ""
}

get_user_choice() {
    local choice
    local default="1"

    if check_existing_session; then
        default="0"
    fi

    printf "Enter your choice [0-5] (default: %s): " "$default" >&2
    read -r choice

    if [ -z "$choice" ]; then
        choice="$default"
    fi

    choice=$(echo "$choice" | tr -d '[:space:]')
    echo "$choice"
}

attach_existing_session() {
    echo "Reconnecting to existing Codex session..."
    sleep 1
    exec tmux attach-session -t "$TMUX_SESSION_NAME"
}

launch_codex_new() {
    echo "Starting new Codex session..."

    if check_existing_session; then
        echo "  (closing previous session)"
        tmux kill-session -t "$TMUX_SESSION_NAME" 2>/dev/null
    fi

    sleep 1
    exec tmux new-session -s "$TMUX_SESSION_NAME" 'codex'
}

launch_codex_custom() {
    echo ""
    echo "Enter your Codex command arguments (example: '--help'):"
    echo -n "> codex "
    read -r custom_args

    if [ -z "$custom_args" ]; then
        echo "No arguments provided. Starting default session..."
        launch_codex_new
    else
        echo "Running: codex $custom_args"

        if check_existing_session; then
            tmux kill-session -t "$TMUX_SESSION_NAME" 2>/dev/null
        fi

        sleep 1
        exec tmux new-session -s "$TMUX_SESSION_NAME" "codex $custom_args"
    fi
}

launch_auth_helper() {
    if [ -x /usr/local/bin/codex-auth-helper ]; then
        exec /usr/local/bin/codex-auth-helper
    fi

    echo "Login helper is unavailable in this build."
    sleep 2
}

launch_bash_shell() {
    echo "Dropping to bash shell..."
    echo "Tip: Run 'tmux new-session -A -s codex \"codex\"' for persistence"
    sleep 1
    exec bash
}

exit_session_picker() {
    echo "Goodbye!"
    exit 0
}

main() {
    while true; do
        show_banner
        show_menu
        choice=$(get_user_choice)

        case "$choice" in
            0)
                if check_existing_session; then
                    attach_existing_session
                else
                    echo "No existing session found"
                    sleep 1
                fi
                ;;
            1)
                launch_codex_new
                ;;
            2)
                launch_codex_custom
                ;;
            3)
                launch_auth_helper
                ;;
            4)
                launch_bash_shell
                ;;
            5)
                exit_session_picker
                ;;
            *)
                echo ""
                echo "Invalid choice: '$choice'"
                echo "Please select a number between 0-5"
                echo ""
                printf "Press Enter to continue..." >&2
                read -r
                ;;
        esac
    done
}

trap 'echo ""; exit 0' EXIT INT TERM

main "$@"