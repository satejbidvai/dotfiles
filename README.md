# dotfiles

My macOS configuration files.

## Contents

| Folder | Tool | Links to |
|---|---|---|
| `hammerspoon/` | [Hammerspoon](https://www.hammerspoon.org) | `~/.hammerspoon` |

### Hammerspoon

- **Zoom:** Closes the "Zoom Workplace" home window when you join a meeting from a link.

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
4. In the Hammerspoon menu, click **Reload Config**.
