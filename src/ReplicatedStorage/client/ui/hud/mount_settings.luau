local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.react)
local mount_portal = require(script.Parent.mount_portal)
local registry = require(script.Parent.registry)
local settings = require(script.Parent.settings)

local function mount_settings(player_gui: PlayerGui, display_order: number, on_close: () -> ())
	local portal = mount_portal(player_gui)
	local function close(): ()
		portal.render(nil)
		on_close()
	end
	local function open(item: registry.entry): ()
		portal.render(
			React.createElement(settings, { selected = item, display_order = display_order, on_close = close })
		)
	end
	return { open = open, close = close, disconnect = portal.disconnect }
end

return mount_settings
