# quickshell-stickynotes

A lightweight, standalone sticky notes widget built with [Quickshell](https://quickshell.outfoxxed.me/), designed to run independently of your main shell config (Noctalia, Caelestia, etc).

![screenshot](./screenshot.png)

## Features

- Persistent sticky notes that survive reboots
- Runs as its own Quickshell instance — doesn't touch your main shell config
- Minimal resource footprint
- Configurable colors/position/font (see [Configuration](#configuration))

## Requirements

- [Quickshell](https://quickshell.outfoxxed.me/) (install via AUR: `yay -S quickshell` or `quickshell-git`)
- A Wayland compositor (tested on Hyprland)
- Qt6 / QML runtime (pulled in as a Quickshell dependency)

## Installation

### Quick install

```bash
git clone https://github.com/<yourusername>/quickshell-stickynotes.git
cd quickshell-stickynotes
./install.sh
```

### Manual install

```bash
git clone https://github.com/<yourusername>/quickshell-stickynotes.git ~/.config/quickshell-stickynotes
```

Add to your `hyprland.conf` (or equivalent compositor config):

```
exec-once = qs -c ~/.config/quickshell-stickynotes
```

Reload your compositor config, or just launch manually to test:

```bash
qs -c ~/.config/quickshell-stickynotes
```

## Configuration

Edit `config.qml` (or `settings.json`, depending on how you structure it) to change:

- Note color/theme
- Default position/size
- Font

```qml
// example config.qml structure
Config {
    noteColor: "#f9e07f"
    fontFamily: "JetBrains Mono"
    defaultWidth: 220
    defaultHeight: 220
}
```

## Data storage

Notes are saved to `~/.local/share/quickshell-stickynotes/notes.json` (XDG-compliant, not hardcoded to a specific user).

## Uninstall

```bash
./uninstall.sh
```

Or manually remove the `exec-once` line from your compositor config and delete `~/.config/quickshell-stickynotes`.

## License

MIT — see [LICENSE](./LICENSE)

## Contributing

PRs welcome, but this is a small personal-itch project — no guarantees on response time.
