local ReplicatedStorage = game:GetService("ReplicatedStorage")

local signal = require(ReplicatedStorage.Packages.signal)

local on_change = signal.new()
-- UI fires this to select a slot, tools.client.luau does the actual switch
local on_select_requested = signal.new()

local state = {
	current = 1,
	on_change = on_change,
	on_select_requested = on_select_requested,
}

local function on_fire(tool: number): ()
	state.current = tool
end

on_change:Connect(on_fire)

return state
