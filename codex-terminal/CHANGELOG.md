# Changelog

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