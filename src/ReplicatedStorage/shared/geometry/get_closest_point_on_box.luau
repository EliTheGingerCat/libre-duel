-- the point on or inside the box nearest to the given point, which is the point itself if it's inside
const function get_closest_point_on_box(point: Vector3, box_cframe: CFrame, box_size: Vector3): Vector3
	const local_point = box_cframe:PointToObjectSpace(point)
	const half_size = box_size / 2
	const clamped_local_point = Vector3.new(
		math.clamp(local_point.X, -half_size.X, half_size.X),
		math.clamp(local_point.Y, -half_size.Y, half_size.Y),
		math.clamp(local_point.Z, -half_size.Z, half_size.Z)
	)
	return box_cframe:PointToWorldSpace(clamped_local_point)
end

return get_closest_point_on_box
