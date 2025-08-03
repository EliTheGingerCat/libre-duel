local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player_voxel_range = require(ReplicatedStorage.modules.player_voxel_range)

local player_voxel_range_server = player_voxel_range + 6

return player_voxel_range_server
