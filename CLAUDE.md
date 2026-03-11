# CLAUDE.md

This file provides repository guidance for coding agents working in this repo.

## Project Overview

This repository contains Home Assistant add-ons, currently focused on **Codex Terminal** in `codex-terminal/`.

## Development Commands

```bash
# Build add-on image
podman build --build-arg BUILD_FROM=ghcr.io/home-assistant/amd64-base:3.19 -t local/codex-terminal ./codex-terminal

# Run locally
podman run -p 7681:7681 -v $(pwd)/config:/config local/codex-terminal

# Lint Dockerfile
hadolint ./codex-terminal/Dockerfile

# Test web endpoint
curl -X GET http://localhost:7681/
```

## Architecture

- `codex-terminal/config.yaml`: Home Assistant add-on manifest and options.
- `codex-terminal/Dockerfile`: Image build with `@openai/codex` installed globally.
- `codex-terminal/run.sh`: Runtime init (`/data`-rooted env), helper wiring, tmux + ttyd launch.
- `codex-terminal/scripts/*`: Session picker, auth helper, diagnostics, and utility scripts.

## Runtime Notes

- Terminal starts in `/config`.
- Persistent runtime state lives in `/data`.
- Codex state directory is `CODEX_HOME=/data/.codex`.
- `auto_launch_codex` is preferred; `auto_launch_claude` is deprecated fallback only.