const ReplicatedStorage = game:GetService("ReplicatedStorage")
const ServerScriptService = game:GetService("ServerScriptService")

const conch = require(ReplicatedStorage.Packages.conch)
const dirty_guild_scores = require(ServerScriptService.guild.ranking.dirty_guild_scores)
const drop = require(ServerScriptService.ServerPackages.drop)
const get_guild_score = require(ServerScriptService.guild.ranking.get_guild_score)
const guild_leaderboard_store = require(ServerScriptService.guild.ranking.guild_leaderboard_store)
const guild_session_refcount = require(ServerScriptService.guild.session.guild_session_refcount)
const guild_store = require(ServerScriptService.guild.data.guild_store)
const refresh_guild_ranks = require(ServerScriptService.guild.ranking.refresh_guild_ranks)

const function get_arguments() end

-- saves every dirty score now instead of waiting for the flush loop, then rereads the leaderboard
const function force_guild_rank_refresh(): string
	for guild_id in dirty_guild_scores do
		dirty_guild_scores[guild_id] = nil
		if guild_session_refcount.is_active(guild_id) then
			const data = drop.view(guild_store, guild_id)
			pcall(guild_leaderboard_store.SetAsync, guild_leaderboard_store, guild_id, get_guild_score(data))
		end
	end
	return if refresh_guild_ranks() then "Guild ranks refreshed" else "Could not read the guild leaderboard"
end

conch.register("force_guild_rank_refresh", {
	description = "Saves pending guild scores and rereads the guild leaderboard",
	permissions = { "administrator" },
	arguments = get_arguments,
	callback = force_guild_rank_refresh,
})
