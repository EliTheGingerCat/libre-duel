local Players = game:GetService("Players")

const get_melee_ray = require(script.Parent.get_melee_ray)

local local_player = Players.LocalPlayer

const function get_mouse_target(): BasePart?
	local unit_ray = get_melee_ray()

	if not (local_player.Character and local_player.Character.PrimaryPart) then
		return nil
	end

	local ray_params = RaycastParams.new()
	ray_params.FilterType = Enum.RaycastFilterType.Exclude
	ray_params.FilterDescendantsInstances = { local_player.Character }
	ray_params.CollisionGroup = "hitbox"

	local ray_result = workspace:Raycast(unit_ray.Origin, unit_ray.Direction * 255, ray_params)

	if ray_result then
		return ray_result.Instance
	end
	return nil
end

return get_mouse_target
