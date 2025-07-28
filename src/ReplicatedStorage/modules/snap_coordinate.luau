local ReplicatedStorage = game:GetService("ReplicatedStorage")

local cube_size = require(ReplicatedStorage.modules.cube_size)

local function snap_coordinate(coordinate: number): number
	return math.round(coordinate / cube_size) * cube_size
end

return snap_coordinate