local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.react)
local mount_portal = require(script.Parent.Parent.mount_portal)
local hud_widget_selector = require(script.Parent.hud_widget_selector)

export type controller = { set_enabled: (boolean) -> (), disconnect: () -> () }

const function mount_hud_widget_selector(player_gui: PlayerGui, display_order: number, on_close: () -> ()): controller
	local portal = mount_portal(player_gui)
	const function close(): ()
		portal.render(nil)
		on_close()
	end
	const function set_enabled(enabled: boolean): ()
		portal.render(
			React.createElement(
				hud_widget_selector,
				{ enabled = enabled, display_order = display_order, on_close = close }
			)
		)
	end
	return { set_enabled = set_enabled, disconnect = portal.disconnect }
end

return mount_hud_widget_selector
