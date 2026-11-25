const Workspace = game:GetService("Workspace")

-- here pitch is positive looking down and yaw is positive turning right, roblox is the opposite for both
local unwrapped_yaw = 0
local previous_raw_yaw: number? = nil

const function get_first_person_camera_rotation(): (number, number)
	const camera = Workspace.CurrentCamera
	if camera == nil then
		return 0, unwrapped_yaw
	end
	const look = camera.CFrame.LookVector
	const pitch = -math.deg(math.asin(math.clamp(look.Y, -1, 1)))
	const raw_yaw = -math.deg(math.atan2(-look.X, -look.Z))
	if previous_raw_yaw ~= nil then
		unwrapped_yaw += (raw_yaw - previous_raw_yaw + 180) % 360 - 180
	else
		unwrapped_yaw = raw_yaw
	end
	previous_raw_yaw = raw_yaw
	return pitch, unwrapped_yaw
end

return get_first_person_camera_rotation
