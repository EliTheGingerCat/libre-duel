local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local knockback_multiplier = require(ServerScriptService.combat.knockback_multiplier)

local conch = require(ReplicatedStorage.Packages.conch)

conch.register("tweak_knockback", {
	description = "Mess around with the knockback values",
	permissions = { "administrator" },
	arguments = function()
		return conch.args.number("x", "New x value"), conch.args.number("y", "New y value")
	end,

	callback = function(x, y)
		knockback_multiplier.X = x
		knockback_multiplier.Y = y

		return `Got it! New values: {knockback_multiplier.X}, {knockback_multiplier.Y}.`
	end,
})
