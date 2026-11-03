local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Signal = require(ReplicatedStorage.Packages.signal)
local cursor_state = require(script.Parent.Parent.cursor_state)

local mode_selector_state = {
	enabled = false,
	on_change = Signal.new(),
}

local function set_enabled(enabled: boolean): ()
	if mode_selector_state.enabled == enabled then
		return
	end
	mode_selector_state.enabled = enabled
	cursor_state.set_free("mode_selector", enabled)
	mode_selector_state.on_change:Fire()
end

mode_selector_state.set_enabled = set_enabled

return mode_selector_state
