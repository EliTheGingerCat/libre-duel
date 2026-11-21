const ReplicatedStorage = game:GetService("ReplicatedStorage")
const ServerScriptService = game:GetService("ServerScriptService")

const GUILD_LIMITS = require(ReplicatedStorage.shared.guild.GUILD_LIMITS)
const guild_leaderboard_store = require(ServerScriptService.guild.ranking.guild_leaderboard_store)

const PAGE_SIZE = 100

-- pages through the top of the leaderboard, nil when any read fails so a half read never replaces good ranks
-- guilds with a score of 0 are skipped, otherwise every new guild would be "ranked"
const function fetch_guild_ranks(): { [string]: number }?
	const ok, pages = pcall(guild_leaderboard_store.GetSortedAsync, guild_leaderboard_store, false, PAGE_SIZE, 1)
	if not ok then
		warn(`Could not read guild ranks: {pages}`)
		return nil
	end
	const ranks: { [string]: number } = {}
	local rank = 0
	while true do
		for _, entry in pages:GetCurrentPage() do
			rank += 1
			ranks[entry.key] = rank
		end
		if pages.IsFinished or rank >= GUILD_LIMITS.MAX_TRACKED_RANK then
			return ranks
		end
		const advanced, message = pcall(pages.AdvanceToNextPageAsync, pages)
		if not advanced then
			warn(`Could not read guild ranks: {message}`)
			return nil
		end
	end
end

return fetch_guild_ranks
