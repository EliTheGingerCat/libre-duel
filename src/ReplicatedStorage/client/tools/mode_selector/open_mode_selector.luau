const ReplicatedStorage = game:GetService("ReplicatedStorage")

const mode_selector_state = require(ReplicatedStorage.client.ui.matchmaking.mode_selector_state)

local function open_mode_selector(): ()
	mode_selector_state.set_enabled(true)
end

return open_mode_selector
