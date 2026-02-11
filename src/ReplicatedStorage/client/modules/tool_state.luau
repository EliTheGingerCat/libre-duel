local ReplicatedStorage = game:GetService("ReplicatedStorage")

local signal = require(ReplicatedStorage.vendor.signal)

local on_change: signal.Signal<number> = signal.new()

local state = {
	current = 1,
	on_change = on_change,
}

local function on_fire(tool: number): ()
	state.current = tool
end

on_change:Connect(on_fire)

return state
