# Codex Terminal for Home Assistant

A secure, web-based terminal with OpenAI Codex CLI pre-installed for Home Assistant.

## Credits

This add-on is ported from the original Claude Terminal add-on by Tom Cassady ([@heytcass](https://github.com/heytcass)).
This repository builds on that original work by replacing Claude-specific implementation details with Codex CLI.

![Codex Terminal Screenshot](https://github.com/moosnelly/ha-codex/raw/main/codex-terminal/screenshot.png)

## Features

- Web terminal via Home Assistant ingress
- Auto-launch Codex on terminal open
- Optional interactive session picker mode
- tmux session persistence across reconnects
- Direct access to `/config`
- Persistent APK and pip package installation

## Quick Start

```bash
codex
codex --help
persist-install list
persist-install apk vim htop
persist-install pip requests
```

## Installation

1. Add `https://github.com/moosnelly/ha-codex` to Home Assistant add-on repositories.
2. Install **Codex Terminal**.
3. Start the add-on.
4. Open the Web UI.

For existing installations, update the add-on and restart once to apply new scrollback behavior. No manual migration is required.

## Configuration

| Option | Default | Description |
|---|---|---|
| `auto_launch_codex` | `true` | Auto-start Codex on terminal open |
| `terminal_scrollback_lines` | `100000` | Terminal and tmux history depth for scrollback |
| `persistent_apk_packages` | `[]` | APK packages to install on startup |
| `persistent_pip_packages` | `[]` | pip packages to install on startup |

Deprecated compatibility option:
- `auto_launch_claude` is still honored when `auto_launch_codex` is unset.

## Authentication

Codex supports:
- Interactive sign-in flow when you run `codex`
- API key auth with `OPENAI_API_KEY`

Persistent Codex state is stored in `CODEX_HOME=/data/.codex`.

## Notes

Breaking change in v2:
- Add-on slug changed from `claude_terminal` to `codex_terminal`.
- Existing users must install the new add-on identity and migrate settings manually.
- Runtime compatibility: `auto_launch_claude` is accepted only as a deprecated fallback when `auto_launch_codex` is unset.

## License

MIT. See [../LICENSE](../LICENSE).
