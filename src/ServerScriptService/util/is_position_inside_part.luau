const function is_position_inside_part(position: Vector3, part: BasePart): boolean
	const local_position = part.CFrame:PointToObjectSpace(position)
	const half_size = part.Size / 2
	return math.abs(local_position.X) <= half_size.X
		and math.abs(local_position.Y) <= half_size.Y
		and math.abs(local_position.Z) <= half_size.Z
end

return is_position_inside_part
