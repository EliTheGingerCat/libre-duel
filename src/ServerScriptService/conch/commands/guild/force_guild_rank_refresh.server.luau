const ReplicatedStorage = game:GetService("ReplicatedStorage")
const ServerScriptService = game:GetService("ServerScriptService")

const conch = require(ReplicatedStorage.Packages.conch)
const flush_guild_scores = require(ServerScriptService.guild.ranking.flush_guild_scores)
const refresh_guild_ranks = require(ServerScriptService.guild.ranking.refresh_guild_ranks)

const function get_arguments() end

-- saves every dirty score now instead of waiting for the flush loop, then rereads the leaderboard
const function force_guild_rank_refresh(): string
	flush_guild_scores()
	return if refresh_guild_ranks() then "Guild ranks refreshed" else "Could not read the guild leaderboard"
end

conch.register("force_guild_rank_refresh", {
	description = "Saves pending guild scores and rereads the guild leaderboard",
	permissions = { "administrator" },
	arguments = get_arguments,
	callback = force_guild_rank_refresh,
})
