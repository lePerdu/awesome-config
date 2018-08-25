-----------------------------------------------------------------------------------------------------------------------
--                                                  Menu config                                                      --
-----------------------------------------------------------------------------------------------------------------------

local start_time, end_time

-- Grab environment
local beautiful = require("beautiful")
local redflat = require("redflat")
local awful = require("awful")
local naughty = require("naughty")


-- Initialize tables and vars for module
-----------------------------------------------------------------------------------------------------------------------
local menu = {}

-- Build function
--------------------------------------------------------------------------------
function menu:init(args)

    -- vars
    local args = args or {}
    local env = args.env or {} -- fix this?
    local separator = args.separator or { widget = redflat.gauge.separator.horizontal() }
    local theme = args.theme or { auto_hotkey = true }
    local icon_style = args.icon_style or {}

    -- theme vars
    local deficon = redflat.util.base.placeholder()
    local icon = redflat.util.table.check(beautiful, "icon.awesome") and beautiful.icon.awesome or deficon
    local color = redflat.util.table.check(beautiful, "color.icon") and beautiful.color.icon or nil

	-- icon finder
	local function micon(name)
		return redflat.service.dfparser.lookup_icon(name, icon_style)
	end

    -- Application submenu
    ------------------------------------------------------------

    -- WARNING!
    -- 'dfparser' module used to parse available desktop files for building application list and finding app icons,
    -- it may cause significant delay on wm start/restart due to the synchronous type of the scripts.
    -- This issue can be reduced by using additional settings like custom desktop files directory
    -- and user only icon theme. See colored configs for more details.

    -- At worst, you can give up all applications widgets (appmenu, applauncher, appswitcher, qlaunch) in your config
    start_time = os.clock()
    local appmenu = redflat.service.dfparser.menu({
        icons = icon_style,
        wm_name = "awesome",
        desktop_file_dirs = {
            "/usr/share/applications",
            "/usr/local/share/applications",
            "/home/zach/.local/share/applications"
        }
    })
    end_time = os.clock()
    times.appmenu = end_time - start_time

    -- Main menu
    ------------------------------------------------------------
    start_time = os.clock()
    self.mainmenu = redflat.menu({ theme = theme,
        items = {
            { "Awesome",  {
                { "Exit",    awesome.quit, micon('system-log-out') },
                { "Restart", awesome.restart, micon('system-restart') },
            }, icon },
            { "Applications",  appmenu, micon('application-menu')},
            { "Terminal",      env.terminal, micon('utilities-terminal') },
            { "Browser",       "chromium", micon('web-browser') },
            separator,
            { "Power", {
                { "Lock",     env.lock_cmd, micon('system-lock-screen') },
                { "Logout",   awesome.quit, micon('system-log-out') },
                { "Shutdown", env.shutdown_cmd, micon('system-shutdown') },
                { "Reboot",   env.reboot_cmd, micon('system-reboot') },
                { "Suspend",  env.suspend_cmd, micon('system-suspend') },
            }},
        }
    })
    end_time = os.clock()
    times.mainmenu = end_time  - start_time

    -- Menu panel widget
    ------------------------------------------------------------

    start_time = os.clock()

    -- widget
    self.widget = redflat.gauge.svgbox(icon, nil, color)
    self.buttons = awful.util.table.join(
        awful.button({ }, 1, function () self.mainmenu:toggle() end)
    )
    end_time = os.clock()
    times.widget  = end_time - start_time
end

-- End
-----------------------------------------------------------------------------------------------------------------------
return menu
