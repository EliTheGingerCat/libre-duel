local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

const GAMEPAD_KEYBINDS = require(script.Parent.GAMEPAD_KEYBINDS)
const KEYBINDS = require(script.Parent.KEYBINDS)
const zap_client_network = require(ReplicatedStorage.client.network.zap_client_network)

type click_type = "attack" | "use"

const CLICK_TYPES: { [Enum.UserInputType]: click_type } = {
	[KEYBINDS.tool_attack] = "attack",
	[KEYBINDS.tool_use] = "use",
}

-- trigger pulls count towards the server's cps check like a mouse click would
const GAMEPAD_CLICK_TYPES: { [Enum.KeyCode]: click_type } = {
	[GAMEPAD_KEYBINDS.tool_attack] = "attack",
	[GAMEPAD_KEYBINDS.tool_use] = "use",
}

const function on_input_began(input: InputObject): ()
	const click_type: click_type? = CLICK_TYPES[input.UserInputType] or GAMEPAD_CLICK_TYPES[input.KeyCode]
	if click_type ~= nil then
		zap_client_network.mouse_click.fire(click_type)
	end
end

UserInputService.InputBegan:Connect(on_input_began)
