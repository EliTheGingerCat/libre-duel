-- shared by the local hit guess and the swing sent to the server, so both aim along the exact same ray
const function get_melee_ray(): Ray
	const camera = workspace.CurrentCamera
	const screen_center = camera.ViewportSize / 2
	return camera:ScreenPointToRay(screen_center.X, screen_center.Y)
end

return get_melee_ray
