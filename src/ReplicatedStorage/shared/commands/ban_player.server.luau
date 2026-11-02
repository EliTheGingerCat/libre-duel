local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local conch = require(ReplicatedStorage.Packages.conch)
conch.register("ban", {
    description = "Bans the given player from the game",
	permissions = { "administrator" },
	arguments = function()
            return conch.args.player("player", "The player that should be banned from the game"),
            conch.args.string("reason", "The reason why the player has been banned from the user."),
            conch.args.number("duration", "The duration of the ban in seconds.")
	end,
    callback = function(player, reason, duration) -- typechecked!
        local context = conch.get_command_context()
        local executing_player = context.executor.player.UserId or "an unknown user"

        Players:BanAsync({
                UserIds = player.UserId,
                Duration = duration,
                DisplayReason = reason,
                PrivateReason = `Banned by {executing_player}`,
                ExcludeAltAccounts = false,
                ApplyToUniverse = true,
        })
end,
})
