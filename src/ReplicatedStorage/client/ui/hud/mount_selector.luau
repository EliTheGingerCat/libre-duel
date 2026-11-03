local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.react)
local mount_portal = require(script.Parent.mount_portal)
local selector = require(script.Parent.selector)

local function mount_selector(player_gui: PlayerGui, display_order: number, on_close: () -> ())
	local portal = mount_portal(player_gui)
	local function close(): ()
		portal.render(nil)
		on_close()
	end
	local function set_enabled(enabled: boolean): ()
		portal.render(
			React.createElement(selector, { enabled = enabled, display_order = display_order, on_close = close })
		)
	end
	return { set_enabled = set_enabled, disconnect = portal.disconnect }
end

return mount_selector
