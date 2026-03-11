# Codex Terminal for Home Assistant

This repository contains a Home Assistant add-on that runs OpenAI Codex CLI inside a Home Assistant ingress terminal.

## Credits

This add-on is a Codex port of the original Claude Terminal add-on created by Tom Cassady ([@heytcass](https://github.com/heytcass)).
The original project and implementation approach are credited to the original author.

## Installation

1. In Home Assistant, open **Settings -> Add-ons -> Add-on Store**.
2. Open the three-dot menu and select **Repositories**.
3. Add: `https://github.com/moosnelly/ha-codex`.
4. Install **Codex Terminal**.

## Add-ons

### Codex Terminal

A web terminal add-on with Codex CLI preinstalled.

Features:
- Ingress web terminal in Home Assistant
- Auto-launch Codex (or session picker mode)
- tmux-backed persistent terminal sessions
- Access to `/config`
- Persistent package installs (`persist-install`)

Important migration note:
- Version 2 changed add-on identity from `claude-terminal`/`claude_terminal` to `codex-terminal`/`codex_terminal`.
- Existing users must install the new add-on and migrate settings manually.

Documentation: [codex-terminal/DOCS.md](codex-terminal/DOCS.md)

## Support

Open an issue in this repository for bugs or feature requests.

## License

MIT. See [LICENSE](LICENSE).
