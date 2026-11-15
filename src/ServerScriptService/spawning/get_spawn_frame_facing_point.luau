-- the target is flattened to the spawn's height so the frame only has yaw
const function get_spawn_frame_facing_point(spawn_position: Vector3, target: Vector3): CFrame
	const flat_target = Vector3.new(target.X, spawn_position.Y, target.Z)
	return CFrame.lookAt(spawn_position, flat_target)
end

return get_spawn_frame_facing_point
