const UserInputService = game:GetService("UserInputService")

const CAMERA_CONSTANTS = require(script.Parent.CAMERA_CONSTANTS)
const cursor_state = require(script.Parent.Parent.ui.cursor_state)

local unlocked = false

const function on_input_began(input: InputObject, processed: boolean): ()
	if processed or input.KeyCode ~= CAMERA_CONSTANTS.unlock_key then
		return
	end
	unlocked = not unlocked
	cursor_state.set_free("control_unlock", unlocked)
end

UserInputService.InputBegan:Connect(on_input_began)
