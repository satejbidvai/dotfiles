# dotfiles

My macOS configuration files.

## Contents

| Folder | Tool | Links to |
|---|---|---|
| `hammerspoon/` | [Hammerspoon](https://www.hammerspoon.org) | `~/.hammerspoon` |

### Hammerspoon

`init.lua` only loads modules. Each automation is one file in `hammerspoon/modules/`.

| Module | What it does |
|---|---|
| `reload.lua` | Reloads the config when a `.lua` file changes. |
| `zoom.lua` | Closes the "Zoom Workplace" home window when you join a meeting from a link. |
| `no_music.lua` | Quits Apple Music immediately each time it starts. This stops the Play key or headphone buttons from opening Music when no media app is open. |
| `latch.lua` | Toggles play/pause when an iPhone Shortcut sends `POST /playpause` on port 52824. The token is in the Keychain (service `latch`). Use only on trusted networks. |

To add an automation:

1. Create `hammerspoon/modules/<name>.lua`. It must return a table `M` with a `start()` function.
2. Keep all watchers, timers and hotkeys on `M` (for example `M.watcher = ...`). If you keep them only in local variables, Lua can garbage-collect them and they stop working.
3. Add `require("modules.<name>").start()` to `init.lua`.

To turn off an automation, comment out its line in `init.lua`.

## Set up a new Mac

1. Clone the repository:

   ```bash
   git clone https://github.com/satejbidvai/dotfiles ~/dotfiles
   ```

2. Link the Hammerspoon configuration:

   ```bash
   ln -s ~/dotfiles/hammerspoon ~/.hammerspoon
   ```

3. Give Hammerspoon Accessibility permission (System Settings → Privacy & Security → Accessibility).
4. In the Hammerspoon menu, click **Reload Config**. After this, the config reloads automatically when you save a `.lua` file.
