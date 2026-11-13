const Players = game:GetService("Players")
const ReplicatedStorage = game:GetService("ReplicatedStorage")

const get_aim_ray = require(script.Parent.get_aim_ray)
const input_device = require(ReplicatedStorage.client.util.input_device)

const AIM_DISTANCE = 1000

const local_player = Players.LocalPlayer
const local_mouse = local_player:GetMouse()

const aim_ray_params = RaycastParams.new()
aim_ray_params.FilterType = Enum.RaycastFilterType.Exclude

export type aim_target = {
	instance: BasePart?,
	position: Vector3,
}

-- same as Mouse.Target and Mouse.Hit, but aimed from the screen centre on a gamepad
const function get_aim_target(): aim_target
	if input_device.current ~= "gamepad" then
		return { instance = local_mouse.Target, position = local_mouse.Hit.Position }
	end

	const aim_ray = get_aim_ray()
	aim_ray_params.FilterDescendantsInstances = { local_player.Character }
	const ray_result = workspace:Raycast(aim_ray.Origin, aim_ray.Direction * AIM_DISTANCE, aim_ray_params)
	if ray_result == nil then
		return { instance = nil, position = aim_ray.Origin + aim_ray.Direction * AIM_DISTANCE }
	end
	return { instance = ray_result.Instance, position = ray_result.Position }
end

return get_aim_target
