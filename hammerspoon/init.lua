-- Hammerspoon entry point. Each automation is a module in modules/.
-- To turn off an automation, comment out its line.

require("modules.reload").start()
require("modules.zoom").start()
require("modules.no_music").start()
require("modules.remote_playpause").start()
