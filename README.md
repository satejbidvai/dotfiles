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
| `remote_playpause.lua` | Toggles play/pause on this Mac from an iPhone Shortcut. See [Remote play/pause](#remote-playpause). |

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
5. Set up [Remote play/pause](#remote-playpause).

## Remote play/pause

`remote_playpause.lua` lets an iPhone Shortcut toggle play/pause on this Mac. It works with any app that plays media (Music, Spotify, browser video, podcasts, the TV app).

How it works: the iPhone sends `POST /playpause` with a token in a header. Hammerspoon checks the token and runs `osascript` with a JXA script. The script tells macOS (private MediaRemote framework) to toggle the app that plays media now.

### 1. Make a token on the Mac

The token is in the login Keychain, not in this repository. The login Keychain does not sync between Macs, so each Mac needs its own token.

```bash
security add-generic-password -U -s remote-playpause -a "$USER" -w "$(openssl rand -hex 16)"
```

Then reload Hammerspoon. The module reads the token only at load. If the token is missing, Hammerspoon shows the alert "Remote play/pause: no token in Keychain".

### 2. Get the URL and token

```bash
echo "http://$(scutil --get LocalHostName).local:52824/playpause"
```

```bash
security find-generic-password -s remote-playpause -w
```

The URL uses the Bonjour `.local` name, not the IP address. The IP address can change. If you rename the Mac, the URL changes.

### 3. Make the iPhone Shortcut

1. In the Shortcuts app, make a new shortcut. Add the action **Get Contents of URL**.
2. **URL**: the URL from step 2.
3. Tap **Show More**. Set **Method** to `POST`.
4. Under **Headers**, add a header:
   - Key: `X-Latch-Token` (the same name as `TOKEN_HEADER` in the module)
   - Value: the token from step 2
5. Give it a name (for example "⏯ Mac") and an icon. Add it to a Shortcuts widget on the Home Screen for one-tap access.

The Shortcut syncs with iCloud. On a new Mac you only change the URL and the token value.

### 4. Test

1. Play something on the Mac.
2. Tap the Shortcut on the iPhone. The media must pause. Tap again: it must play.
3. Open the Hammerspoon Console (Hammerspoon menu → **Console**). Each request shows a line, for example `remote_playpause: POST /playpause -> 204`.

### Troubleshooting

| Problem | What to do |
|---|---|
| A tap does nothing | Make sure that the iPhone and the Mac are on the same Wi-Fi network. Look at the Hammerspoon Console. |
| Console shows `-> 401` | The token in the Shortcut is not the same as the token in the Keychain. Copy the token again (step 2). |
| Console shows no line | The request does not get to Hammerspoon. Make sure that the server listens: `lsof -iTCP:52824 -sTCP:LISTEN` must show `Hammerspoon`. On the iPhone, make sure that Shortcuts has Local Network access (Settings → Privacy & Security → Local Network). |
| Requests fail with 400 | The Hammerspoon server rejects a `POST` without a `Content-Length` header. In the Shortcut, set **Request Body** to JSON and add one field (for example `x` = `1`). |
| Port 52824 is in use | Change `PORT` in `remote_playpause.lua` and the URL in the Shortcut. |

Test from the Mac without a toggle (expect `401`):

```bash
curl -s -o /dev/null -w '%{http_code}\n' -X POST -H 'Content-Length: 0' -H 'X-Latch-Token: wrong' http://localhost:52824/playpause
```

### Change the token

Run the command in step 1 again, reload Hammerspoon, and update the header value in the Shortcut.

### Security

The server uses plain HTTP and listens on all network interfaces. On a public Wi-Fi network, another person can see the token and use it. The token can only toggle play/pause.

To run the server only on your home Wi-Fi, put the network names in `HOME_SSIDS` in `remote_playpause.lua`. Then give Hammerspoon Location Services access (System Settings → Privacy & Security → Location Services), because macOS shows the Wi-Fi name only to apps that have this access.
