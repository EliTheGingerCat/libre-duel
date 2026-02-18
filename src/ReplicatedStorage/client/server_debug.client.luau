local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local keybinds = require(script.Parent.modules.keybinds)

local function on_input_began(input: InputObject): ()
	if input.KeyCode == keybinds.debug_server then
		ReplicatedStorage.remotes.debug_server:FireServer()
	end
end

UserInputService.InputBegan:Connect(on_input_began)
