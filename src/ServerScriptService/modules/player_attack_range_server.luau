local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player_attack_range = require(ReplicatedStorage.modules.player_attack_range)

local player_attack_range_server = player_attack_range + 6

return player_attack_range_server
