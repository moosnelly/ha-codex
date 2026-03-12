# Codex Terminal

A terminal interface for OpenAI Codex CLI in Home Assistant.

## About

This add-on provides a web-based terminal with Codex pre-installed and launches from Home Assistant ingress.

## Installation

1. Add this repository in Home Assistant.
2. Install **Codex Terminal**.
3. Start the add-on.
4. Open Web UI.

## Configuration

- `auto_launch_codex` (default `true`)
- `terminal_scrollback_lines` (default `100000`)
- `persistent_apk_packages`
- `persistent_pip_packages`

Backward-compatible fallback:
- `auto_launch_claude` is read only when `auto_launch_codex` is unset.

## Usage

```bash
codex
codex --help
```

The terminal starts in `/config`.

Session behavior:
- Auto-launch mode starts Codex in tmux.
- Session-picker mode allows reconnect/new/custom command/bash.
- Mouse wheel scrolling works in the terminal and traverses tmux history.
- Use `terminal_scrollback_lines` to tune retained terminal history.

## Authentication

- Run `codex` for interactive sign-in.
- Or set `OPENAI_API_KEY` before launching Codex.
- Codex state persists under `/data/.codex`.

## Troubleshooting

- Check add-on logs in Home Assistant.
- Verify connectivity to `api.openai.com`.
- Refresh UI and reconnect; tmux session should persist.
