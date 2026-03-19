local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player_range = require(ReplicatedStorage.shared.combat.player_range)

local player_range_server = player_range + 6

return player_range_server
