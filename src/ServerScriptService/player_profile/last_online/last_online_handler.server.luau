const Players = game:GetService("Players")
const ReplicatedStorage = game:GetService("ReplicatedStorage")
const ServerScriptService = game:GetService("ServerScriptService")

const PLAYER_PROFILE_LIMITS = require(ReplicatedStorage.shared.player_profile.PLAYER_PROFILE_LIMITS)
const drop = require(ServerScriptService.ServerPackages.drop)
const get_cached_player_data = require(ServerScriptService.player_data.get_cached_player_data)
const on_session_stopping = require(ServerScriptService.player_data.session.on_session_stopping)
const player_schema = require(ServerScriptService.player_data.schema.player_schema)
const player_store = require(ServerScriptService.player_data.player_store)

const function set_last_online_to_now(data: player_schema.player_data): player_schema.player_data
	const new_data = table.clone(data)
	new_data.last_online = os.time()
	return new_data
end

const function bump_last_online(player: Player): ()
	drop.update(player_store, tostring(player.UserId), set_last_online_to_now)
end

-- bumped on an interval as well, so players in other servers read as online for whoever views them
-- how fresh that looks from another server also depends on how often drop saves
on_session_stopping(bump_last_online)

while true do
	for _, player in Players:GetPlayers() do
		if get_cached_player_data(player) then
			bump_last_online(player)
		end
	end
	task.wait(PLAYER_PROFILE_LIMITS.LAST_ONLINE_INTERVAL)
end
