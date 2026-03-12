#!/usr/bin/with-contenv bashio

set -e
set -o pipefail

get_terminal_scrollback_lines() {
    local default_lines=100000
    local min_lines=1000
    local max_lines=500000
    local configured_lines

    if bashio::config.has_value 'terminal_scrollback_lines'; then
        configured_lines=$(bashio::config 'terminal_scrollback_lines')
    else
        configured_lines="$default_lines"
    fi

    if ! [[ "$configured_lines" =~ ^[0-9]+$ ]]; then
        bashio::log.warning "Invalid terminal_scrollback_lines value '${configured_lines}'. Using default ${default_lines}."
        echo "$default_lines"
        return
    fi

    if [ "$configured_lines" -lt "$min_lines" ]; then
        bashio::log.warning "terminal_scrollback_lines ${configured_lines} is below minimum ${min_lines}. Clamping to ${min_lines}."
        echo "$min_lines"
        return
    fi

    if [ "$configured_lines" -gt "$max_lines" ]; then
        bashio::log.warning "terminal_scrollback_lines ${configured_lines} is above maximum ${max_lines}. Clamping to ${max_lines}."
        echo "$max_lines"
        return
    fi

    echo "$configured_lines"
}

init_environment() {
    local data_home="/data/home"
    local config_dir="/data/.config"
    local cache_dir="/data/.cache"
    local state_dir="/data/.local/state"
    local codex_home="/data/.codex"

    bashio::log.info "Initializing Codex environment in /data..."

    if ! mkdir -p "$data_home" "$config_dir" "$cache_dir" "$state_dir" "/data/.local/share" "$codex_home"; then
        bashio::log.error "Failed to create directories in /data"
        exit 1
    fi

    chmod 755 "$data_home" "$config_dir" "$cache_dir" "$state_dir" "/data/.local" "/data/.local/share" "$codex_home"

    export HOME="$data_home"
    export XDG_CONFIG_HOME="$config_dir"
    export XDG_CACHE_HOME="$cache_dir"
    export XDG_STATE_HOME="$state_dir"
    export XDG_DATA_HOME="/data/.local/share"
    export CODEX_HOME="$codex_home"

    archive_legacy_claude_auth

    if [ -f "/opt/scripts/tmux.conf" ]; then
        cp /opt/scripts/tmux.conf "$data_home/.tmux.conf"
        chmod 644 "$data_home/.tmux.conf"
        bashio::log.info "tmux configuration installed to $data_home/.tmux.conf"
    fi

    bashio::log.info "Environment initialized:"
    bashio::log.info "  - Home: $HOME"
    bashio::log.info "  - Config: $XDG_CONFIG_HOME"
    bashio::log.info "  - Cache: $XDG_CACHE_HOME"
    bashio::log.info "  - CODEX_HOME: $CODEX_HOME"
}

archive_legacy_claude_auth() {
    local marker="/data/.codex/.claude_auth_archive_complete"
    local archive_root="/data/.codex/legacy-claude-auth"
    local timestamp
    timestamp="$(date +%Y%m%d%H%M%S)"
    local legacy_locations=(
        "/root/.config/anthropic"
        "/root/.anthropic"
        "/config/claude-config"
        "/tmp/claude-config"
    )

    if [ -f "$marker" ]; then
        return
    fi

    local found=false
    for legacy_path in "${legacy_locations[@]}"; do
        if [ -d "$legacy_path" ] && [ "$(ls -A "$legacy_path" 2>/dev/null)" ]; then
            if [ "$found" = false ]; then
                mkdir -p "$archive_root/$timestamp"
                found=true
            fi

            bashio::log.info "Archiving legacy Claude auth files from: $legacy_path"
            cp -a "$legacy_path" "$archive_root/$timestamp/" 2>/dev/null || bashio::log.warning "Failed to archive: $legacy_path"
        fi
    done

    touch "$marker"

    if [ "$found" = true ]; then
        bashio::log.info "Archived legacy Claude auth files to: $archive_root/$timestamp"
    fi
}

install_tools() {
    bashio::log.info "Installing additional runtime tools..."
    if ! apk add --no-cache ttyd jq curl tmux; then
        bashio::log.error "Failed to install required tools"
        exit 1
    fi
    bashio::log.info "Tools installed successfully"
}

install_persistent_packages() {
    bashio::log.info "Checking for persistent packages..."

    local persist_config="/data/persistent-packages.json"
    local apk_packages=""
    local pip_packages=""

    if bashio::config.has_value 'persistent_apk_packages'; then
        local config_apk
        config_apk=$(bashio::config 'persistent_apk_packages')
        if [ -n "$config_apk" ] && [ "$config_apk" != "null" ]; then
            apk_packages="$config_apk"
            bashio::log.info "Found APK packages in config: $apk_packages"
        fi
    fi

    if bashio::config.has_value 'persistent_pip_packages'; then
        local config_pip
        config_pip=$(bashio::config 'persistent_pip_packages')
        if [ -n "$config_pip" ] && [ "$config_pip" != "null" ]; then
            pip_packages="$config_pip"
            bashio::log.info "Found pip packages in config: $pip_packages"
        fi
    fi

    if [ -f "$persist_config" ]; then
        bashio::log.info "Found local persistent packages config"

        local local_apk
        local local_pip
        local_apk=$(jq -r '.apk_packages | join(" ")' "$persist_config" 2>/dev/null || echo "")
        local_pip=$(jq -r '.pip_packages | join(" ")' "$persist_config" 2>/dev/null || echo "")

        if [ -n "$local_apk" ]; then
            apk_packages="$apk_packages $local_apk"
        fi
        if [ -n "$local_pip" ]; then
            pip_packages="$pip_packages $local_pip"
        fi
    fi

    apk_packages=$(echo "$apk_packages" | tr ' ' '\n' | sort -u | tr '\n' ' ' | xargs)
    pip_packages=$(echo "$pip_packages" | tr ' ' '\n' | sort -u | tr '\n' ' ' | xargs)

    if [ -n "$apk_packages" ]; then
        bashio::log.info "Installing persistent APK packages: $apk_packages"
        # shellcheck disable=SC2086
        if apk add --no-cache $apk_packages; then
            bashio::log.info "APK packages installed successfully"
        else
            bashio::log.warning "Some APK packages failed to install"
        fi
    fi

    if [ -n "$pip_packages" ]; then
        bashio::log.info "Installing persistent pip packages: $pip_packages"
        # shellcheck disable=SC2086
        if pip3 install --break-system-packages --no-cache-dir $pip_packages; then
            bashio::log.info "pip packages installed successfully"
        else
            bashio::log.warning "Some pip packages failed to install"
        fi
    fi

    if [ -z "$apk_packages" ] && [ -z "$pip_packages" ]; then
        bashio::log.info "No persistent packages configured"
    fi
}

setup_helpers() {
    if [ -f "/opt/scripts/codex-session-picker.sh" ]; then
        cp /opt/scripts/codex-session-picker.sh /usr/local/bin/codex-session-picker
        chmod +x /usr/local/bin/codex-session-picker
        bashio::log.info "Session picker script installed successfully"
    else
        bashio::log.warning "Session picker script not found, using auto-launch mode only"
    fi

    if [ -f "/opt/scripts/codex-auth-helper.sh" ]; then
        cp /opt/scripts/codex-auth-helper.sh /usr/local/bin/codex-auth-helper
        chmod +x /usr/local/bin/codex-auth-helper
        bashio::log.info "Auth helper script installed successfully"
    fi

    if [ -f "/opt/scripts/persist-install.sh" ]; then
        if cp /opt/scripts/persist-install.sh /usr/local/bin/persist-install; then
            chmod +x /usr/local/bin/persist-install
            bashio::log.info "Persist-install script installed successfully"
        else
            bashio::log.warning "Failed to copy persist-install script"
        fi
    fi
}

get_auto_launch_codex() {
    if bashio::config.has_value 'auto_launch_codex'; then
        bashio::config 'auto_launch_codex'
        return
    fi

    if bashio::config.has_value 'auto_launch_claude'; then
        bashio::log.warning "'auto_launch_claude' is deprecated. Please use 'auto_launch_codex'."
        bashio::config 'auto_launch_claude'
        return
    fi

    echo "true"
}

get_codex_launch_command() {
    local history_limit="$1"
    local auto_launch_codex
    auto_launch_codex=$(get_auto_launch_codex)

    if [ "$auto_launch_codex" = "true" ]; then
        echo "tmux set-option -g history-limit ${history_limit} >/dev/null 2>&1; tmux new-session -A -s codex 'codex'"
    else
        if [ -f /usr/local/bin/codex-session-picker ]; then
            echo "tmux set-option -g history-limit ${history_limit} >/dev/null 2>&1; tmux new-session -A -s codex-picker '/usr/local/bin/codex-session-picker'"
        else
            bashio::log.warning "Session picker not found, falling back to auto-launch"
            echo "tmux set-option -g history-limit ${history_limit} >/dev/null 2>&1; tmux new-session -A -s codex 'codex'"
        fi
    fi
}

start_web_terminal() {
    local port=7681
    bashio::log.info "Starting web terminal on port ${port}..."

    bashio::log.info "Environment variables:"
    bashio::log.info "CODEX_HOME=${CODEX_HOME}"
    bashio::log.info "HOME=${HOME}"

    local terminal_scrollback_lines
    terminal_scrollback_lines=$(get_terminal_scrollback_lines)
    bashio::log.info "Terminal scrollback lines: ${terminal_scrollback_lines}"

    local launch_command
    launch_command=$(get_codex_launch_command "$terminal_scrollback_lines")

    local auto_launch_codex
    auto_launch_codex=$(get_auto_launch_codex)
    bashio::log.info "Auto-launch Codex: ${auto_launch_codex}"

    export TTYD=1

    exec ttyd \
        --port "${port}" \
        --interface 0.0.0.0 \
        --writable \
        --ping-interval 30 \
        --client-option enableReconnect=true \
        --client-option reconnect=10 \
        --client-option reconnectInterval=5 \
        --client-option scrollback="${terminal_scrollback_lines}" \
        bash -c "$launch_command"
}

run_health_check() {
    if [ -f "/opt/scripts/health-check.sh" ]; then
        bashio::log.info "Running system health check..."
        chmod +x /opt/scripts/health-check.sh
        /opt/scripts/health-check.sh || bashio::log.warning "Some health checks failed but continuing..."
    fi
}

main() {
    bashio::log.info "Initializing Codex Terminal add-on..."

    run_health_check
    init_environment
    install_tools
    setup_helpers
    install_persistent_packages
    start_web_terminal
}

main "$@"
