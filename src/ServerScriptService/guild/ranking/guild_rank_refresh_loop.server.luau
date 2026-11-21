const refresh_guild_ranks = require(script.Parent.refresh_guild_ranks)

const REFRESH_INTERVAL = 300

while true do
	refresh_guild_ranks()
	task.wait(REFRESH_INTERVAL)
end
