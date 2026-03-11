# Development Status

## Current State

The repository has been ported from Claude Terminal to Codex Terminal.

Implemented:
- Add-on directory renamed to `codex-terminal/`.
- Slug changed to `codex_terminal`.
- Runtime now installs and launches OpenAI Codex CLI (`codex`).
- Persistent state rooted in `/data` with `CODEX_HOME=/data/.codex`.
- tmux-backed terminal persistence preserved.
- Session picker updated for Codex-safe commands.
- Docs and metadata updated to Codex branding.
- Claude-specific CI workflows removed.

Compatibility:
- `auto_launch_codex` is the primary option.
- `auto_launch_claude` is still honored as deprecated fallback.