-- Apple Music: quit it immediately each time it starts.
-- When no app is playing media, the Play key (or a headphone button) makes
-- macOS (rcd) start Apple Music. Hammerspoon cannot stop rcd, so this module
-- quits Music after it starts. Do not use this module if you use Apple Music.

local M = {}

local MUSIC_BUNDLE = "com.apple.Music"

local function quit(app)
  if not app then return end
  app:hide()
  app:kill9()
end

function M.start()
  -- Music can already be open when the config loads.
  for _, app in ipairs(hs.application.applicationsForBundleID(MUSIC_BUNDLE)) do
    quit(app)
  end

  -- Keep the watcher on M, so Lua does not garbage-collect it.
  M.appWatcher = hs.application.watcher.new(function(_, event, app)
    if app and app:bundleID() == MUSIC_BUNDLE
      and (event == hs.application.watcher.launching or event == hs.application.watcher.launched) then
      quit(app)
    end
  end)
  M.appWatcher:start()

  return M
end

return M
