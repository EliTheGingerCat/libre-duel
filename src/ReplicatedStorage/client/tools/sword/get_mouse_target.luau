local Players = game:GetService("Players")

local local_player = Players.LocalPlayer

local function get_mouse_target(): BasePart?
	local local_camera = workspace.CurrentCamera
	local screen_center = local_camera.ViewportSize / 2

	local unit_ray = local_camera:ScreenPointToRay(screen_center.X, screen_center.Y)

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
