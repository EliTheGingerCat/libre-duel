local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

const KEYBINDS = require(script.Parent.KEYBINDS)
const zap_client_network = require(ReplicatedStorage.client.network.zap_client_network)

const function on_input_began(input: InputObject): ()
	if input.KeyCode == KEYBINDS.debug_server then
		zap_client_network.debug_server.fire()
	end
end

UserInputService.InputBegan:Connect(on_input_began)
