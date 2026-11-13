local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

const GAMEPAD_KEYBINDS = require(script.Parent.GAMEPAD_KEYBINDS)
const KEYBINDS = require(script.Parent.KEYBINDS)

const CLICK_TYPES = {
	[KEYBINDS.tool_attack] = "attack",
	[KEYBINDS.tool_use] = "use",
}

-- trigger pulls count towards the server's cps check like a mouse click would
const GAMEPAD_CLICK_TYPES = {
	[GAMEPAD_KEYBINDS.tool_attack] = "attack",
	[GAMEPAD_KEYBINDS.tool_use] = "use",
}

const function on_input_began(input: InputObject): ()
	const click_type = CLICK_TYPES[input.UserInputType] or GAMEPAD_CLICK_TYPES[input.KeyCode]
	if click_type ~= nil then
		ReplicatedStorage.remotes.mouse_click:FireServer(click_type)
	end
end

UserInputService.InputBegan:Connect(on_input_began)
