local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.react)
local mount_portal = require(script.Parent.Parent.mount_portal)
local hud_registry = require(script.Parent.Parent.registry.hud_registry)
local hud_settings = require(script.Parent.hud_settings)

export type controller = { open: (hud_registry.entry) -> (), close: () -> (), disconnect: () -> () }

const function mount_hud_settings(player_gui: PlayerGui, display_order: number, on_close: () -> ()): controller
	local portal = mount_portal(player_gui)
	const function close(): ()
		portal.render(nil)
		on_close()
	end
	const function open(item: hud_registry.entry): ()
		portal.render(
			React.createElement(hud_settings, { selected = item, display_order = display_order, on_close = close })
		)
	end
	return { open = open, close = close, disconnect = portal.disconnect }
end

return mount_hud_settings
