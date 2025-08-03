local ReplicatedStorage = game:GetService("ReplicatedStorage")

local voxel_size = require(ReplicatedStorage.modules.voxel_size)

local function snap_coordinate(coordinate: number): number
	return math.round(coordinate / voxel_size) * voxel_size
end

return snap_coordinate
