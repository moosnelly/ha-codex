#!/bin/bash

show_menu() {
    clear
    echo "==============================================="
    echo "               Codex Login Helper"
    echo "==============================================="
    echo ""
    echo "Official sign-in options:"
    echo "  1) Start Codex interactive login"
    echo "  2) Show API key environment setup"
    echo "  3) Exit"
    echo ""
}

start_interactive_login() {
    echo "Starting Codex..."
    echo "Follow the on-screen prompts to sign in with ChatGPT or use an API key."
    sleep 1
    exec codex
}

show_api_key_help() {
    echo ""
    echo "API key setup:"
    echo "  export OPENAI_API_KEY=\"your_api_key\""
    echo ""
    echo "Optional in this shell only:"
    echo "  OPENAI_API_KEY=\"your_api_key\" codex"
    echo ""
    echo "Press Enter to return..."
    read -r
}

main() {
    while true; do
        show_menu
        echo -n "Enter your choice [1-3]: "
        read -r choice

        case "$choice" in
            1)
                start_interactive_login
                ;;
            2)
                show_api_key_help
                ;;
            3)
                exit 0
                ;;
            *)
                echo "Invalid choice"
                sleep 1
                ;;
        esac
    done
}

main "$@"
