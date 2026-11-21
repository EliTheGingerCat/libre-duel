const flush_guild_scores = require(script.Parent.flush_guild_scores)
const refresh_guild_ranks = require(script.Parent.refresh_guild_ranks)

const FLUSH_INTERVAL = 30
const REFRESH_INTERVAL = 300

-- one loop so a guild that just got its first score is ranked on the next flush instead of up to 5 minutes later
local last_refresh = -math.huge
while true do
	const saved_unranked_guild = flush_guild_scores()
	if saved_unranked_guild or os.clock() - last_refresh >= REFRESH_INTERVAL then
		if refresh_guild_ranks() then
			last_refresh = os.clock()
		end
	end
	task.wait(FLUSH_INTERVAL)
end
