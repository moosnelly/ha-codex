# Development Guide

This guide covers local development and testing workflows for the Codex Terminal add-on.

## Quick Start

```bash
podman build --build-arg BUILD_FROM=ghcr.io/home-assistant/amd64-base:3.19 \
  -t local/codex-terminal:test ./codex-terminal

mkdir -p /tmp/test-config
echo '{"auto_launch_codex": false}' > /tmp/test-config/options.json

podman run -d --name test-codex-dev \
  -p 7681:7681 \
  -v /tmp/test-config:/config \
  local/codex-terminal:test

podman logs test-codex-dev
```

## Useful Commands

```bash
podman exec -it test-codex-dev /bin/bash
podman exec test-codex-dev env | grep -E 'CODEX|XDG|HOME'
podman exec test-codex-dev /usr/local/bin/codex-session-picker
podman logs -f test-codex-dev
```

## Cleanup

```bash
podman stop test-codex-dev && podman rm test-codex-dev
podman rmi local/codex-terminal:test
```