-----------------------------------------------------------------------------------------------------------------------
--                                                Colorless config                                                   --
-----------------------------------------------------------------------------------------------------------------------

-- Load modules
-----------------------------------------------------------------------------------------------------------------------

local start_time, end_time
times = {}

start_time = os.clock()

naughty = require("naughty")

-- Standard awesome library
------------------------------------------------------------
local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local menu_utils = require("menubar.utils")

require("awful.autofocus")

-- User modules
------------------------------------------------------------
local redflat = require("redflat")


-- Error handling
-----------------------------------------------------------------------------------------------------------------------
require("colorless.ercheck-config") -- load file with error handling



-- Setup theme and environment vars
-----------------------------------------------------------------------------------------------------------------------
local env = require("colorless.env-config") -- load file with environment
env:init({
    terminal = "termite",
    fm = "ranger",
    shutdown_cmd = "sudo poweroff",
    reboot_cmd = "sudo reboot",
    suspend_cmd = "sudo zzz",
    hibernate_cmd = "sudo ZZZ",
    lock_cmd = "xautolock -locknow"
})

-- Layouts setup
-----------------------------------------------------------------------------------------------------------------------
local layouts = require("colorless.layout-config") -- load file with tile layouts setup
layouts:init({
    env = env,
})


-- Main menu configuration
-----------------------------------------------------------------------------------------------------------------------
local mymenu = require("colorless.menu-config") -- load file with menu configuration
mymenu:init({
    env = env,
    icon_style = {
        theme = "/usr/share/icons/Paper"
    }
})


-- Panel widgets
-----------------------------------------------------------------------------------------------------------------------

-- Separator
--------------------------------------------------------------------------------
local separator = redflat.gauge.separator.vertical()

-- Tasklist
--------------------------------------------------------------------------------
local tasklist = {}

tasklist.buttons = awful.util.table.join(
	awful.button({}, 1, redflat.widget.tasklist.action.select),
	awful.button({}, 2, redflat.widget.tasklist.action.close),
	awful.button({}, 3, redflat.widget.tasklist.action.menu),
	awful.button({}, 4, redflat.widget.tasklist.action.switch_next),
	awful.button({}, 5, redflat.widget.tasklist.action.switch_prev)
)

-- Taglist widget
--------------------------------------------------------------------------------
local taglist = {}
taglist.style = { widget = redflat.gauge.tag.orange.new, show_tip = true }
taglist.buttons = awful.util.table.join(
	awful.button({         }, 1, function(t) t:view_only() end),
	awful.button({ env.mod }, 1, function(t) if client.focus then client.focus:move_to_tag(t) end end),
	awful.button({         }, 2, awful.tag.viewtoggle),
	awful.button({         }, 3, function(t) redflat.widget.layoutbox:toggle_menu(t) end),
	awful.button({ env.mod }, 3, function(t) if client.focus then client.focus:toggle_tag(t) end end),
	awful.button({         }, 4, function(t) awful.tag.viewnext(t.screen) end),
	awful.button({         }, 5, function(t) awful.tag.viewprev(t.screen) end)
)

-- Textclock widget
--------------------------------------------------------------------------------
local textclock = {}
textclock.widget = redflat.widget.textclock({ timeformat = "%H:%M", dateformat = "%b  %d  %a" })

-- Volume widget
--------------------------------------------------------------------------------
local volume = {}
redflat.widget.alsa.card = 1
volume.widget = redflat.widget.alsa(nil, { widget = redflat.gauge.audio.red.new })

-- activate player widget
-- redflat.float.player:init({ name = env.player })

volume.buttons = awful.util.table.join(
    awful.button({}, 1, function() redflat.widget.alsa:mute()                         end),
    awful.button({}, 4, function() redflat.widget.alsa:change_volume({ down = true }) end),
    awful.button({}, 5, function() redflat.widget.alsa:change_volume()                end)
    -- awful.button({}, 3, function() redflat.float.player:show()                         end),
    -- awful.button({}, 2, function() redflat.float.player:action("PlayPause")            end),
	-- awful.button({}, 8, function() redflat.float.player:action("Previous")             end),
	-- awful.button({}, 9, function() redflat.float.player:action("Next")                 end)
)


-- System monitor
--------------------------------------------------------------------------------

local sysmon = { widget = {}, buttons = {} }

-- battery
sysmon.widget.battery = redflat.widget.sysmon(
	{ func = redflat.system.pformatted.bat(15), arg = "BAT0" },
	{
	    timeout = 2,
	    widget = redflat.gauge.icon.single,
	    monitor = {
	        is_vertical = true,
	        icon = redflat.util.table.check(beautiful, "icon.widget.battery"),
	    },
	}
)

-- network speed
sysmon.widget.network = redflat.widget.net(
	{
		interface = "wlp3s0",
		speed = { up = 6 * 1024^2, down = 6 * 1024^2 },
		autoscale = false
	},
	{ timeout = 2, widget = redflat.gauge.icon.double }
)

-- CPU usage
sysmon.widget.cpu = redflat.widget.sysmon(
	{ func = redflat.system.pformatted.cpu(80) },
	{ timeout = 2, widget = redflat.gauge.monitor.dash }
)

sysmon.buttons.cpu = awful.util.table.join(
	awful.button({ }, 1, function() redflat.float.top:show("cpu") end)
)

-- RAM usage
sysmon.widget.ram = redflat.widget.sysmon(
	{ func = redflat.system.pformatted.mem(70) },
	{ timeout = 10, widget = redflat.gauge.monitor.dash }
)

sysmon.buttons.ram = awful.util.table.join(
	awful.button({ }, 1, function() redflat.float.top:show("mem") end)
)


-- Layoutbox configure
--------------------------------------------------------------------------------
local layoutbox = {}

layoutbox.buttons = awful.util.table.join(
	awful.button({ }, 1, function () awful.layout.inc( 1) end),
	awful.button({ }, 3, function () redflat.widget.layoutbox:toggle_menu(mouse.screen.selected_tag) end),
	awful.button({ }, 4, function () awful.layout.inc( 1) end),
	awful.button({ }, 5, function () awful.layout.inc(-1) end)
)

-- Tray widget
--------------------------------------------------------------------------------
local tray = {}
tray.widget = redflat.widget.minitray()

tray.buttons = awful.util.table.join(
	awful.button({}, 1, function() redflat.widget.minitray:toggle() end)
)


-- Screen setup
-----------------------------------------------------------------------------------------------------------------------
awful.screen.connect_for_each_screen(
	function(s)
		-- wallpaper
		env.wallpaper(s)

		-- tags
		awful.tag(
		    { "Term", "Web", "Media", "Dev", "Office", "Tag6", "Tag7", "VM", "BG" },
		    s, awful.layout.layouts[1]
        )

		-- layoutbox widget
		layoutbox[s] = redflat.widget.layoutbox({ screen = s })

		-- taglist widget
		taglist[s] = redflat.widget.taglist({ screen = s, buttons = taglist.buttons, hint = env.tagtip }, taglist.style)

		-- tasklist widget
		tasklist[s] = redflat.widget.tasklist({ screen = s, buttons = tasklist.buttons })

		-- panel wibox
		s.panel = awful.wibar({ position = "bottom", screen = s, height = beautiful.panel_height or 36 })

		-- add widgets to the wibox
		s.panel:setup {
			layout = wibox.layout.align.horizontal,
			{ -- left widgets
				layout = wibox.layout.fixed.horizontal,

				env.wrapper(mymenu.widget, "mainmenu", mymenu.buttons),
				separator,
				env.wrapper(layoutbox[s], "layoutbox", layoutbox.buttons),
				separator,
				env.wrapper(taglist[s], "taglist"),
				separator,
				s.mypromptbox,
			},
			{ -- middle widget
				layout = wibox.layout.align.horizontal,
				expand = "outside",

				nil,
				env.wrapper(tasklist[s], "tasklist"),
			},
			{ -- right widgets
				layout = wibox.layout.fixed.horizontal,

                separator,
                env.wrapper(sysmon.widget.network, "network"),
                separator,
                env.wrapper(sysmon.widget.cpu, "cpu", sysmon.buttons.cpu),
                env.wrapper(sysmon.widget.ram, "ram", sysmon.buttons.ram),
                separator,
                env.wrapper(sysmon.widget.battery, "battery"),
				separator,
				env.wrapper(volume.widget, "volume", volume.buttons),
				separator,
				env.wrapper(textclock.widget, "textclock"),
				separator,
				env.wrapper(tray.widget, "tray", tray.buttons),
			},
		}
	end
)



-- Key bindings
-----------------------------------------------------------------------------------------------------------------------
local hotkeys = require("colorless.keys-config") -- load file with hotkeys configuration
hotkeys:init({ env = env, menu = mymenu.mainmenu })


-- Rules
-----------------------------------------------------------------------------------------------------------------------
local rules = require("colorless.rules-config") -- load file with rules configuration
rules:init({
    hotkeys = hotkeys,
})


-- Titlebar setup
-----------------------------------------------------------------------------------------------------------------------
local titlebar = require("colorless.titlebar-config") -- load file with titlebar configuration
titlebar:init()


-- Base signal set for awesome wm
-----------------------------------------------------------------------------------------------------------------------
local signals = require("colorless.signals-config") -- load file with signals configuration
signals:init({ env = env })

-- Initializes the apprunner asynchronously
redflat.float.apprunner:init()

end_time = os.clock()
times.total = end_time - start_time

local str = ''
for k, v in pairs(times) do
    str = str .. k .. ' : ' .. tostring(v) .. '\n'
end
local naughty = require('naughty')
naughty.notify({preset = naughty.config.presets.critical, text = str})

