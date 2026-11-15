-- slab test for one axis, narrowing the [entry, exit] range of the ray that is inside the box
const function clip_ray_to_axis(
	origin_component: number,
	direction_component: number,
	half_extent: number,
	entry: number,
	exit: number
): (number, number)
	if math.abs(direction_component) < 1e-8 then
		if math.abs(origin_component) > half_extent then
			return math.huge, -math.huge
		end
		return entry, exit
	end
	const near = (-half_extent - origin_component) / direction_component
	const far = (half_extent - origin_component) / direction_component
	return math.max(entry, math.min(near, far)), math.min(exit, math.max(near, far))
end

-- direction has to be a unit vector, otherwise the returned distance is scaled by its length
-- an origin inside the box counts as a hit at distance 0
const function get_ray_box_hit_distance(
	origin: Vector3,
	direction: Vector3,
	maximum_distance: number,
	box_cframe: CFrame,
	box_size: Vector3
): number?
	const local_origin = box_cframe:PointToObjectSpace(origin)
	const local_direction = box_cframe:VectorToObjectSpace(direction)
	const half_size = box_size / 2

	const entry_x, exit_x = clip_ray_to_axis(local_origin.X, local_direction.X, half_size.X, 0, maximum_distance)
	const entry_y, exit_y = clip_ray_to_axis(local_origin.Y, local_direction.Y, half_size.Y, entry_x, exit_x)
	const entry_z, exit_z = clip_ray_to_axis(local_origin.Z, local_direction.Z, half_size.Z, entry_y, exit_y)

	if entry_z > exit_z then
		return nil
	end
	return entry_z
end

return get_ray_box_hit_distance
