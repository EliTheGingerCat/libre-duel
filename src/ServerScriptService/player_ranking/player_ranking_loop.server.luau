const Players = game:GetService("Players")

const flush_player_scores = require(script.Parent.flush_player_scores)
const last_saved_player_scores = require(script.Parent.last_saved_player_scores)
const refresh_player_ranks = require(script.Parent.refresh_player_ranks)

const FLUSH_INTERVAL = 30
const REFRESH_INTERVAL = 300

const function forget_saved_score(player: Player): ()
	last_saved_player_scores[player] = nil
end

Players.PlayerRemoving:Connect(forget_saved_score)

-- one loop so a player that just got their first score is ranked on the next flush instead of up to 5 minutes later
local last_refresh = -math.huge
while true do
	const saved_unranked_player = flush_player_scores()
	if saved_unranked_player or os.clock() - last_refresh >= REFRESH_INTERVAL then
		if refresh_player_ranks() then
			last_refresh = os.clock()
		end
	end
	task.wait(FLUSH_INTERVAL)
end
