const ServerScriptService = game:GetService("ServerScriptService")

const dirty_guild_scores = require(script.Parent.dirty_guild_scores)
const drop = require(ServerScriptService.ServerPackages.drop)
const get_guild_score = require(script.Parent.get_guild_score)
const guild_leaderboard_store = require(script.Parent.guild_leaderboard_store)
const guild_session_refcount = require(ServerScriptService.guild.session.guild_session_refcount)
const guild_store = require(ServerScriptService.guild.data.guild_store)

const FLUSH_INTERVAL = 60

-- batched so a match ending doesn't fire one SetAsync per stat
const function flush_dirty_scores(): ()
	for guild_id in dirty_guild_scores do
		dirty_guild_scores[guild_id] = nil
		if guild_session_refcount.is_active(guild_id) then
			const data = drop.view(guild_store, guild_id)
			if not data.deleted then
				const ok, message =
					pcall(guild_leaderboard_store.SetAsync, guild_leaderboard_store, guild_id, get_guild_score(data))
				if not ok then
					warn(`Could not save guild score: {message}`)
					dirty_guild_scores[guild_id] = true
				end
			end
		end
	end
end

while true do
	task.wait(FLUSH_INTERVAL)
	flush_dirty_scores()
end
