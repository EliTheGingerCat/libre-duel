local ReplicatedStorage = game:GetService("ReplicatedStorage")

local signal = require(ReplicatedStorage.Packages.signal)

local on_change = signal.new()
-- UI fires this to select a slot, tools.client.luau does the actual switch
local on_select_requested = signal.new()
-- fires on every attack attempt, even if the attack then fails (out of range, on cooldown, etc.)
local on_attack = signal.new()
-- fires on every use attempt, even if the tool's handler then fails (out of range, occupied, etc.)
local on_use = signal.new()

-- on-screen buttons fire this with ("attack" | "use", is_pressed), tools.client.luau handles it like a mouse button
local on_button_requested = signal.new()

local state = {
	on_button_requested = on_button_requested,
	current = 1,
	on_change = on_change,
	on_select_requested = on_select_requested,
	on_attack = on_attack,
	on_use = on_use,
}

const function on_fire(tool: number): ()
	state.current = tool
end

on_change:Connect(on_fire)

return state
