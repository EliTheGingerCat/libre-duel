local ReplicatedStorage = game:GetService("ReplicatedStorage")

const MELEE_COOLDOWN = require(ReplicatedStorage.shared.combat.MELEE_COOLDOWN)

const MELEE_COOLDOWN_SERVER = MELEE_COOLDOWN - 0.1

return MELEE_COOLDOWN_SERVER
