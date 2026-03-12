# Codex Terminal Home Assistant Add-on Documentation

## Overview

Codex Terminal provides an ingress web terminal for Home Assistant with OpenAI Codex CLI available inside the container.

## Installation

1. Add this repository in Home Assistant Add-on Store repositories.
2. Install **Codex Terminal**.
3. Start the add-on.
4. Open **Web UI** or the sidebar panel.

## Configuration

Optional settings:

- `auto_launch_codex` (default: `true`)
- `terminal_scrollback_lines` (default: `100000`)
- `persistent_apk_packages` (default: `[]`)
- `persistent_pip_packages` (default: `[]`)

Backward compatibility:
- `auto_launch_claude` is still read if `auto_launch_codex` is unset, but it is deprecated.

## Usage

The terminal starts in `/config`.

Common commands:
- `codex`
- `codex --help`
- `persist-install list`
- `persist-install apk vim`
- `persist-install pip requests`

Authentication:
- Sign in interactively from `codex` (ChatGPT sign-in flow), or
- Set an API key: `export OPENAI_API_KEY="..."`.

State persistence:
- Codex state is stored under `CODEX_HOME=/data/.codex`.

## Troubleshooting

1. Check add-on logs from Home Assistant.
2. Verify network access to `api.openai.com`.
3. If terminal disconnects, refresh and reconnect; tmux sessions persist.
4. Mouse wheel scroll should navigate terminal history; increase `terminal_scrollback_lines` if history feels short.

## Security

- Add-on runs in an isolated container.
- Access is scoped to Home Assistant add-on permissions.
- Keep API credentials private.

## Support

Use GitHub issues in this repository.
