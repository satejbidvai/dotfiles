-- Reload the Hammerspoon config when a .lua file in the config folder changes.

local M = {}

local function onChange(paths)
  for _, path in ipairs(paths) do
    if path:sub(-4) == ".lua" then
      hs.reload()
      return
    end
  end
end

function M.start()
  -- ~/.hammerspoon is a symlink. Watch the real folder, because file
  -- system events do not follow symlinks.
  local configDir = hs.fs.pathToAbsolute(hs.configdir)
  M.watcher = hs.pathwatcher.new(configDir, onChange):start()
  hs.alert.show("Hammerspoon config loaded")
  return M
end

return M
