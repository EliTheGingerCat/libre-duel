local ReplicatedStorage = game:GetService("ReplicatedStorage")

local sword_cooldown = require(ReplicatedStorage.modules.sword_cooldown)

local sword_cooldown_server = sword_cooldown - 0.1

return sword_cooldown_server
