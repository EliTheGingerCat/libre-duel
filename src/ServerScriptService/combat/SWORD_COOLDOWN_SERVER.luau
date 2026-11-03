local ReplicatedStorage = game:GetService("ReplicatedStorage")

const SWORD_COOLDOWN = require(ReplicatedStorage.shared.combat.SWORD_COOLDOWN)

const SWORD_COOLDOWN_SERVER = SWORD_COOLDOWN - 0.1

return SWORD_COOLDOWN_SERVER
