const MINIMUM_SEGMENT_LENGTH = 1e-4

-- returns the point where the segment passed the listener, if it crossed the plane
-- through the listener (perpendicular to the flight direction) within the radius
const function get_flyby_crossing(
	previous_position: Vector3,
	current_position: Vector3,
	listener_position: Vector3,
	radius: number
): Vector3?
	const segment = current_position - previous_position
	const segment_length = segment.Magnitude
	if segment_length < MINIMUM_SEGMENT_LENGTH then
		return nil
	end

	const direction = segment / segment_length
	const distance_along_before = (listener_position - previous_position):Dot(direction)
	const distance_along_after = (listener_position - current_position):Dot(direction)
	if distance_along_before < 0 or distance_along_after >= 0 then
		return nil
	end

	const closest_point = previous_position + direction * distance_along_before
	if (listener_position - closest_point).Magnitude > radius then
		return nil
	end

	return closest_point
end

return get_flyby_crossing
