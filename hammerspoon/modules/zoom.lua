-- Zoom: close the home window ("Zoom Workplace") when you join a meeting.

local M = {}

local ZOOM_NAME = "Zoom"
local ZOOM_BUNDLE = "us.zoom.xos"
local HOME_TITLE = "Zoom Workplace"
local LAUNCH_GRACE = 30 -- seconds after launch in which the home window is always closed

local zoomLaunchedAt = 0

local function isHomeWindow(win)
  return win and win:title() == HOME_TITLE
end

-- Zoom adds a "Meeting" menu to the menu bar only during a meeting.
local function inMeeting(app)
  if not app then return false end
  for _, item in ipairs(app:getMenuItems() or {}) do
    if item.AXTitle == "Meeting" then return true end
  end
  return false
end

local function closeHome(win)
  if win and win:isVisible() and isHomeWindow(win) then win:close() end
end

local function onHomeWindow(win)
  if not isHomeWindow(win) then return end
  if os.time() - zoomLaunchedAt > LAUNCH_GRACE and not inMeeting(win:application()) then return end
  closeHome(win)
  -- The home window can reopen while it loads. Try again.
  hs.timer.doAfter(1, function() closeHome(win) end)
  hs.timer.doAfter(3, function() closeHome(win) end)
end

function M.start()
  -- Keep the watchers on M. require() keeps M in package.loaded,
  -- so Lua does not garbage-collect them.
  M.windowFilter = hs.window.filter.new({ ZOOM_NAME })
  M.windowFilter:subscribe({
    hs.window.filter.windowCreated,
    hs.window.filter.windowVisible,
    hs.window.filter.windowTitleChanged,
  }, onHomeWindow)

  M.appWatcher = hs.application.watcher.new(function(_, event, app)
    if event == hs.application.watcher.launching and app and app:bundleID() == ZOOM_BUNDLE then
      zoomLaunchedAt = os.time()
    end
  end)
  M.appWatcher:start()

  return M
end

return M
