const CUBE_SIZE = require(script.Parent.CUBE_SIZE)
const snap_coordinate = require(script.Parent.snap_coordinate)

-- a bit under half a cube, so snapping lands in the cell in front of the face instead of the one that was hit
const FACE_OFFSET = CUBE_SIZE / 2 * 0.9

-- shared so the client's preview and the server's placement always pick the same cell
const function get_cube_placement_position(hit_position: Vector3, hit_normal: Vector3): Vector3
	const offset_position = hit_position + hit_normal * FACE_OFFSET
	return Vector3.new(
		snap_coordinate(offset_position.X),
		snap_coordinate(offset_position.Y),
		snap_coordinate(offset_position.Z)
	)
end

return get_cube_placement_position
