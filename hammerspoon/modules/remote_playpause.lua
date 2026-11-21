-- Remote play/pause: toggle play/pause on this Mac from an iPhone Shortcut.
-- Setup, testing and troubleshooting: "Remote play/pause" in the repository README.
--
-- Hammerspoon cannot use the private MediaRemote framework directly, because
-- macOS 15.4+ lets only entitled clients use it. /usr/bin/osascript is a system
-- binary that has the entitlement, so this module runs the toggle through it.

local M = {}

local PORT = 52824
local ROUTE = "/playpause"
local KEYCHAIN_SERVICE = "remote-playpause"
-- "Latch" is the name of the first version of this tool. Keep this header
-- name: the iPhone Shortcut sends it.
local TOKEN_HEADER = "X-Latch-Token"
-- Wi-Fi names where the server runs. Empty = all networks.
-- A name here needs Location Services for Hammerspoon.
local HOME_SSIDS = {}

-- Command 2 = kMRTogglePlayPause. The delay lets the command complete
-- before osascript exits.
local JXA_TOGGLE = [[
ObjC.import('Foundation');
const MR = $.NSBundle.bundleWithPath('/System/Library/PrivateFrameworks/MediaRemote.framework/');
MR.load;
const ctrl = $.NSClassFromString('MRNowPlayingController').localRouteController;
ctrl.sendCommandOptionsCompletion(2, $.NSDictionary.alloc.init, null);
delay(0.5);
]]

-- Do not log the token, the headers or the query.
local function log(message)
  print("remote_playpause: " .. message)
end

local function readToken()
  local out, ok = hs.execute("/usr/bin/security find-generic-password -s " .. KEYCHAIN_SERVICE .. " -w 2>/dev/null")
  if not ok or not out then return nil end
  local token = out:gsub("%s+", "")
  if #token < 32 then return nil end
  return token
end

-- Header names can have different case. Find the header without case.
local function header(headers, name)
  name = name:lower()
  for k, v in pairs(headers or {}) do
    if k:lower() == name then return v end
  end
  return nil
end

local function toggle()
  M.task = hs.task.new("/usr/bin/osascript", function(exitCode)
    if exitCode ~= 0 then log("osascript failed, exit code " .. exitCode) end
  end, { "-l", "JavaScript", "-e", JXA_TOGGLE })
  M.task:start()
end

local function respond(method, path, code)
  log(string.format("%s %s -> %d", method, path, code))
  return "", code, {}
end

local function handler(method, fullPath, headers)
  local path = fullPath:gsub("%?.*$", "")
  if header(headers, TOKEN_HEADER) ~= M.token then
    return respond(method, path, 401)
  end
  if method == "POST" and path == ROUTE then
    toggle()
    return respond(method, path, 204)
  end
  return respond(method, path, 404)
end

local function onHomeNetwork()
  if #HOME_SSIDS == 0 then return true end
  local ssid = hs.wifi.currentNetwork()
  for _, name in ipairs(HOME_SSIDS) do
    if name == ssid then return true end
  end
  return false
end

local function update()
  local shouldRun = onHomeNetwork()
  if shouldRun and not M.running then
    M.server:start()
    M.running = true
    log("listening on :" .. PORT)
  elseif not shouldRun and M.running then
    M.server:stop()
    M.running = false
    log("stopped (not on a home network)")
  end
end

function M.start()
  M.token = readToken()
  if not M.token then
    hs.alert.show("Remote play/pause: no token in Keychain (service \"" .. KEYCHAIN_SERVICE .. "\")")
    return M
  end

  -- No TLS. No Bonjour advertisement.
  M.server = hs.httpserver.new(false, false)
  M.server:setPort(PORT)
  M.server:setCallback(handler)
  M.running = false
  update()

  if #HOME_SSIDS > 0 then
    M.wifiWatcher = hs.wifi.watcher.new(update):start()
  end

  return M
end

return M
