const ServerScriptService = game:GetService("ServerScriptService")

const active_session_keys = require(ServerScriptService.player_data.session.active_session_keys)
const drop = require(ServerScriptService.ServerPackages.drop)
const player_schema = require(ServerScriptService.player_data.schema.player_schema)
const player_store = require(ServerScriptService.player_data.player_store)

-- works for offline players too, in which case it yields for a datastore read
-- nil when that read fails
const function read_player_data(user_id: number): player_schema.player_data?
	const key = tostring(user_id)
	if active_session_keys[key] then
		return drop.view(player_store, key)
	end
	const ok, data = pcall(drop.viewasync, player_store, key)
	return if ok then data else nil
end

return read_player_data
