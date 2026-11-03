const CUBE_SIZE = require(script.Parent.CUBE_SIZE)

local function snap_coordinate(coordinate: number): number
	return math.round(coordinate / CUBE_SIZE) * CUBE_SIZE
end

return snap_coordinate
