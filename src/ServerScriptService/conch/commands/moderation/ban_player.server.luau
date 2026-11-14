local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local conch = require(ReplicatedStorage.Packages.conch)
local get_executor_player = require(ServerScriptService.conch.get_executor_player)

conch.register("ban", {
	description = "Bans the given player from the game",
	permissions = { "administrator" },
	arguments = function()
		return conch.args.player("player", "The player that should be banned from the game"),
			conch.args.string("reason", "The reason why the player has been banned from the user."),
			conch.args.number("duration", "The duration of the ban in seconds.")
	end,
	callback = function(player, reason, duration) -- typechecked!
		local executor = get_executor_player()
		local executing_player = if executor then executor.UserId else "an unknown user"

		Players:BanAsync({
			UserIds = { player.UserId },
			Duration = duration,
			DisplayReason = reason,
			PrivateReason = `Banned by {executing_player}`,
			ExcludeAltAccounts = false,
			ApplyToUniverse = true,
		})
	end,
})
