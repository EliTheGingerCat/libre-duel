local ReplicatedStorage = game:GetService("ReplicatedStorage")

local signal = require(ReplicatedStorage.Packages.signal)

local mode_selector_state = {
	enabled = false,
	on_change = signal.new(),
}

local function set_enabled(enabled: boolean): ()
	if mode_selector_state.enabled == enabled then
		return
	end
	mode_selector_state.enabled = enabled
	mode_selector_state.on_change:Fire()
end

mode_selector_state.set_enabled = set_enabled

return mode_selector_state
