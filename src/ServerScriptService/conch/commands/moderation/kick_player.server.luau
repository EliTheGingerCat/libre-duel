-- stolen 1:1 from the docs (https://alicesaidhi.github.io/conch/resources/getting-started/5-custom-commands)

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local conch = require(ReplicatedStorage.Packages.conch)

conch.register("kick", {
	description = "Kicks the given player from the server",
	permissions = { "administrator" },
	arguments = function()
		return conch.args.player("player", "The player that should be kicked from the server"),
			conch.args.string("reason", "The reason why the player has been kicked from the user.")
	end,

	callback = function(player, reason) -- typechecked!
		player:Kick(reason)
	end,
})
