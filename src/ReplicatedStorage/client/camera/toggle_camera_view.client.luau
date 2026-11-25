const UserInputService = game:GetService("UserInputService")

const CAMERA_CONSTANTS = require(script.Parent.CAMERA_CONSTANTS)
const camera_view_state = require(script.Parent.camera_view_state)

const function on_input_began(input: InputObject, processed: boolean): ()
	if processed or input.KeyCode ~= CAMERA_CONSTANTS.toggle_key then
		return
	end
	camera_view_state.set_third_person(not camera_view_state.third_person)
end

UserInputService.InputBegan:Connect(on_input_began)
