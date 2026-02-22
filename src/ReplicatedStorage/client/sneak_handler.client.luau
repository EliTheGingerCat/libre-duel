local UserInputService = game:GetService("UserInputService")

local keybinds = require(script.Parent.modules.keybinds)
local set_player_sneak = require(script.Parent.modules.set_player_sneak)

local function on_input_began(input: InputObject, gameProcessed: boolean)
	if gameProcessed then return end

	if input.KeyCode == keybinds.player_sneak then
		set_player_sneak(true)
	end
end

local function on_input_ended(input: InputObject, gameProcessed: boolean)
	if gameProcessed then return end

	if input.KeyCode == keybinds.player_sneak then
		set_player_sneak(false)
	end
end

UserInputService.InputBegan:Connect(on_input_began)
UserInputService.InputEnded:Connect(on_input_ended)
