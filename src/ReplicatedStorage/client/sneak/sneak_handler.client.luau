local UserInputService = game:GetService("UserInputService")

const KEYBINDS = require(script.Parent.Parent.util.KEYBINDS)
local set_player_sneak = require(script.Parent.set_player_sneak)

local function on_input_began(input: InputObject, gameProcessed: boolean)
	if gameProcessed then
		return
	end

	if input.KeyCode == KEYBINDS.player_sneak then
		set_player_sneak(true)
	end
end

local function on_input_ended(input: InputObject, gameProcessed: boolean)
	if gameProcessed then
		return
	end

	if input.KeyCode == KEYBINDS.player_sneak then
		set_player_sneak(false)
	end
end

UserInputService.InputBegan:Connect(on_input_began)
UserInputService.InputEnded:Connect(on_input_ended)
