const Players = game:GetService("Players")
const ReplicatedStorage = game:GetService("ReplicatedStorage")
const UserInputService = game:GetService("UserInputService")

const cake_state = require(script.Parent.cake_state)
const KEYBINDS = require(ReplicatedStorage.client.util.KEYBINDS)
const slot_has_behaviour = require(ReplicatedStorage.client.tools.slot_has_behaviour)
const tool_state = require(ReplicatedStorage.client.tools.tool_state)

const set_cake_state = ReplicatedStorage.remotes.set_cake_state

const player = Players.LocalPlayer

local eating: boolean = false
local eating_buffer: boolean = false

local function eat_cake(): ()
	if slot_has_behaviour(tool_state.current, "cake") then
		eating = true
		cake_state.eating = true
		local finished = set_cake_state:InvokeServer(eating)
		if finished then
			eating = false
			cake_state.eating = false
            -- do something...
		else
            -- do something...
		end
	end
end

--buffer system (if you hold then equip the apple, it will eat)
local function on_input_began(input: InputObject): ()
	if input.UserInputType ~= KEYBINDS.tool_use then
		return
	end
	eating_buffer = true
end

local function cancel_eat(): ()
	cake_state.eating = false
	if eating == true then
		eating = false
		set_cake_state:InvokeServer(eating)
	end
end

local function tool_change(): ()
	if not slot_has_behaviour(tool_state.current, "cake") then
		cancel_eat()
	elseif eating_buffer == true and eating == false then
		eat_cake()
	end
end

-- cancels whatever the release landed on, otherwise releasing over UI would keep the eat going
local function on_input_ended(input: InputObject): ()
	if input.UserInputType ~= KEYBINDS.tool_use then
		return
	end
	eating_buffer = false
	cancel_eat()
end

UserInputService.InputEnded:Connect(on_input_ended)
UserInputService.InputBegan:Connect(on_input_began)
UserInputService.WindowFocusReleased:Connect(cancel_eat)
player.CharacterRemoving:Connect(cancel_eat)
tool_state.on_change:Connect(tool_change)

return eat_cake
