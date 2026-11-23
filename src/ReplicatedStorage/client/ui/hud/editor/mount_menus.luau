local mount_hud_widget_selector = require(script.Parent.Parent.widget_selector.mount_hud_widget_selector)
local mount_hud_settings = require(script.Parent.Parent.settings.mount_hud_settings)
local hud_registry = require(script.Parent.Parent.registry.hud_registry)

export type controller = {
	close: () -> (),
	open_selector: () -> (),
	open_settings: (hud_registry.entry) -> (),
	is_open: () -> boolean,
	disconnect: () -> (),
}

const function mount_menus(player_gui: PlayerGui, display_order: number, on_changed: (boolean) -> ()): controller
	local enabled = false
	const function set_open(open: boolean): ()
		if enabled == open then
			return
		end
		enabled = open
		on_changed(open)
	end
	const function on_close(): ()
		set_open(false)
	end
	local selector = mount_hud_widget_selector(player_gui, display_order, on_close)
	local settings = mount_hud_settings(player_gui, display_order, on_close)

	const function close(): ()
		selector.set_enabled(false)
		settings.close()
		set_open(false)
	end

	const function open_selector(): ()
		close()
		set_open(true)
		selector.set_enabled(true)
	end

	const function open_settings(item: hud_registry.entry): ()
		close()
		set_open(true)
		settings.open(item)
	end

	const function is_open(): boolean
		return enabled
	end

	const function disconnect(): ()
		selector.disconnect()
		settings.disconnect()
	end

	return {
		close = close,
		open_selector = open_selector,
		open_settings = open_settings,
		is_open = is_open,
		disconnect = disconnect,
	}
end

return mount_menus
