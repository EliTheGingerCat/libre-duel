local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local React = require(ReplicatedStorage.Packages.react)

local use_effect = React.useEffect
local use_state = React.useState

-- `key` must be constant.
local function use_if_key_held(key: Enum.KeyCode): boolean
	local held, set_held = use_state(UserInputService:IsKeyDown(key))

	use_effect(function()
		local function on_input_began(input: InputObject): ()
			if input.KeyCode == key then
				set_held(true)
			end
		end

		local connection_began = UserInputService.InputBegan:Connect(on_input_began)

		local function on_input_ended(input: InputObject): ()
			if input.KeyCode == key then
				set_held(false)
			end
		end

		local connection_ended = UserInputService.InputEnded:Connect(on_input_ended)

		local function destroy()
			connection_began:Disconnect()
			connection_ended:Disconnect()
		end

		return destroy
	end, {}) -- Zero dependencies since `key` is constant.

	return held
end

return use_if_key_held
