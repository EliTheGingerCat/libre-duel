const Players = game:GetService("Players")
const ServerScriptService = game:GetService("ServerScriptService")

const award_player_stat = require(ServerScriptService.player_data.awarding.award_player_stat)
const on_session_stopping = require(ServerScriptService.player_data.session.on_session_stopping)
const server_join_times = require(script.Parent.server_join_times)

const function on_player_joined(player: Player): ()
	server_join_times[player] = os.time()
end

const function award_session_playtime(player: Player): ()
	const join_time = server_join_times[player]
	server_join_times[player] = nil
	if join_time == nil then
		return
	end
	award_player_stat(player, "playtime", os.time() - join_time)
end

Players.PlayerAdded:Connect(on_player_joined)
on_session_stopping(award_session_playtime)

for _, player in Players:GetPlayers() do
	on_player_joined(player)
end
