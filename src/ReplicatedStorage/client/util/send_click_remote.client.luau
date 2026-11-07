local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

const KEYBINDS = require(script.Parent.KEYBINDS)

const CLICK_TYPES = {
	[KEYBINDS.tool_attack] = "attack",
	[KEYBINDS.tool_use] = "use",
}

local function on_input_began(input: InputObject): ()
	const click_type = CLICK_TYPES[input.UserInputType]
	if click_type ~= nil then
		ReplicatedStorage.remotes.mouse_click:FireServer(click_type)
	end
end

UserInputService.InputBegan:Connect(on_input_began)
