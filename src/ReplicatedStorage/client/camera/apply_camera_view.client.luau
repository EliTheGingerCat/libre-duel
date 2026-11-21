const Players = game:GetService("Players")

const CAMERA_CONSTANTS = require(script.Parent.CAMERA_CONSTANTS)
const camera_view_state = require(script.Parent.camera_view_state)

const local_player = Players.LocalPlayer

const function apply_camera_view(third_person: boolean): ()
	if third_person then
		local_player.CameraMode = Enum.CameraMode.Classic
		-- the engine rejects a minimum above the maximum, so the order depends on which way the range moves
		local_player.CameraMaxZoomDistance = CAMERA_CONSTANTS.third_person_zoom
		local_player.CameraMinZoomDistance = CAMERA_CONSTANTS.third_person_zoom
	else
		local_player.CameraMinZoomDistance = CAMERA_CONSTANTS.first_person_zoom
		local_player.CameraMaxZoomDistance = CAMERA_CONSTANTS.first_person_zoom
		local_player.CameraMode = Enum.CameraMode.LockFirstPerson
	end
end

apply_camera_view(camera_view_state.third_person)
camera_view_state.changed:Connect(apply_camera_view)
