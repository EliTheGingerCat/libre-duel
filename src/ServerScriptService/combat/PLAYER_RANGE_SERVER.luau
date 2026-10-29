local ReplicatedStorage = game:GetService("ReplicatedStorage")

const PLAYER_RANGE = require(ReplicatedStorage.shared.combat.PLAYER_RANGE)

const PLAYER_RANGE_SERVER = PLAYER_RANGE + 6

return PLAYER_RANGE_SERVER
