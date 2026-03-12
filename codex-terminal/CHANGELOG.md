# Changelog

## 2.0.1

### Added
- Added optional `terminal_scrollback_lines` configuration (default `100000`) to tune terminal and tmux scrollback depth.

### Changed
- Wired ttyd client scrollback to the configured history limit.
- Aligned tmux history behavior with configured scrollback for better long-session navigation.
- Improved mouse-wheel scrolling behavior in the web terminal so history is easier to traverse.

### Compatibility
- No manual migration required for existing installations.
- Existing installs pick up defaults automatically after update + add-on restart.

## 2.0.0

### Breaking
- Renamed add-on directory `claude-terminal` -> `codex-terminal`.
- Changed add-on slug `claude_terminal` -> `codex_terminal`.

### Changed
- Replaced Claude CLI with OpenAI Codex CLI.
- Docker image now installs Codex via `npm i -g @openai/codex`.
- Runtime environment now uses `CODEX_HOME=/data/.codex`.
- Session picker updated for Codex-safe commands.
- Added Codex login helper script with official sign-in/API key guidance.
- Updated health checks to validate Codex/OpenAI connectivity.
- Updated docs/metadata/branding from Claude to Codex.

### Compatibility
- `auto_launch_codex` introduced as preferred option.
- `auto_launch_claude` remains a deprecated runtime fallback.
