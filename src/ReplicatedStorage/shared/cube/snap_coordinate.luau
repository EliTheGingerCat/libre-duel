local cube_size = require(script.Parent.cube_size)

local function snap_coordinate(coordinate: number): number
	return math.round(coordinate / cube_size) * cube_size
end

return snap_coordinate
