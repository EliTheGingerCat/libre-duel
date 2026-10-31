const Players = game:GetService("Players")
const ReplicatedStorage = game:GetService("ReplicatedStorage")
const UserInputService = game:GetService("UserInputService")

const editor_state = require(ReplicatedStorage.client.ui.hud.editor_state)
const KEYBINDS = require(ReplicatedStorage.client.util.KEYBINDS)
const tool_state = require(ReplicatedStorage.client.ui.tool_state)
const TOOLS = require(ReplicatedStorage.client.ui.TOOL_LIST)

const set_cake_state = ReplicatedStorage.remotes.set_cake_state

const player = Players.LocalPlayer
const character = player.Character or player.CharacterAdded:Wait()

local eating: boolean = false
local eating_buffer: boolean = false

local function eat_cake()
	if TOOLS[tool_state.current] == "cake" then
		eating = true
		local finished = set_cake_state:InvokeServer(eating)
		if finished then
            -- do something...
		else
            -- do something...
		end
	end
end

--buffer system (if you hold then equip the apple, it will eat)
local function on_input_began(input: InputObject)
	if input.UserInputType ~= KEYBINDS.tool_use then
		return
	end
	eating_buffer = true
end

local function tool_change()
	if eating_buffer == true then
		eat_cake()
	end
end

local function cancel_eat()
	if eating == true then
		eating = false
		set_cake_state:InvokeServer(eating)
	end
end

local function on_input_ended(input: InputObject, game_processed: boolean): ()
	if input.UserInputType ~= KEYBINDS.tool_use then
		return
	end
	eating_buffer = false
	if game_processed or editor_state.enabled or TOOLS[tool_state.current] ~= "cake" then
		return
	end
	if eating == false or character == nil or character ~= player.Character then
		return
	end
	cancel_eat()
end

UserInputService.InputEnded:Connect(on_input_ended)
UserInputService.InputBegan:Connect(on_input_began)
UserInputService.WindowFocusReleased:Connect(cancel_eat)
player.CharacterRemoving:Connect(cancel_eat)
tool_state.on_change:Connect(tool_change)

return eat_cake
