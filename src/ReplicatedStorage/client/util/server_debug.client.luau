local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

const KEYBINDS = require(script.Parent.KEYBINDS)

const function on_input_began(input: InputObject): ()
	if input.KeyCode == KEYBINDS.debug_server then
		ReplicatedStorage.remotes.debug_server:FireServer()
	end
end

UserInputService.InputBegan:Connect(on_input_began)
