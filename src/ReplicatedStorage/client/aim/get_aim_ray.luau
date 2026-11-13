const Players = game:GetService("Players")
const ReplicatedStorage = game:GetService("ReplicatedStorage")

const input_device = require(ReplicatedStorage.client.util.input_device)

const local_mouse = Players.LocalPlayer:GetMouse()

-- a gamepad never moves the mouse, so its stale position would aim wherever the cursor was last left
const function get_aim_ray(): Ray
	if input_device.current ~= "gamepad" then
		return local_mouse.UnitRay
	end
	const camera = workspace.CurrentCamera
	const viewport_center = camera.ViewportSize / 2
	return camera:ViewportPointToRay(viewport_center.X, viewport_center.Y)
end

return get_aim_ray
