local mount_selector = require(script.Parent.mount_selector)
local mount_settings = require(script.Parent.mount_settings)
local registry = require(script.Parent.registry)

export type controller = {
	close: () -> (),
	open_selector: () -> (),
	open_settings: (registry.entry) -> (),
	is_open: () -> boolean,
	disconnect: () -> (),
}

local function mount_menus(player_gui: PlayerGui, display_order: number, on_changed: (boolean) -> ()): controller
	local enabled = false
	local function set_open(open: boolean): ()
		if enabled == open then
			return
		end
		enabled = open
		on_changed(open)
	end
	local function on_close(): ()
		set_open(false)
	end
	local selector = mount_selector(player_gui, display_order, on_close)
	local settings = mount_settings(player_gui, display_order, on_close)

	local function close(): ()
		selector.set_enabled(false)
		settings.close()
		set_open(false)
	end

	local function open_selector(): ()
		close()
		set_open(true)
		selector.set_enabled(true)
	end

	local function open_settings(item: registry.entry): ()
		close()
		set_open(true)
		settings.open(item)
	end

	local function is_open(): boolean
		return enabled
	end

	local function disconnect(): ()
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
