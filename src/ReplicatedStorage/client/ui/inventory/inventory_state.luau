local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Signal = require(ReplicatedStorage.Packages.signal)
local cursor_state = require(script.Parent.Parent.cursor_state)

local inventory_state = {
	enabled = false,
	on_change = Signal.new(),
}

const function set_enabled(enabled: boolean): ()
	if inventory_state.enabled == enabled then
		return
	end
	inventory_state.enabled = enabled
	cursor_state.set_free("inventory", enabled)
	inventory_state.on_change:Fire()
end

inventory_state.set_enabled = set_enabled

return inventory_state
