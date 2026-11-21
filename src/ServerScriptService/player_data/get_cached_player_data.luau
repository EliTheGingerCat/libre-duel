const ServerScriptService = game:GetService("ServerScriptService")

const active_session_keys = require(ServerScriptService.player_data.session.active_session_keys)
const drop = require(ServerScriptService.ServerPackages.drop)
const player_schema = require(ServerScriptService.player_data.schema.player_schema)
const player_store = require(ServerScriptService.player_data.player_store)

-- never yields, nil until the player's session finished loading on this server
const function get_cached_player_data(player: Player): player_schema.player_data?
	const key = tostring(player.UserId)
	if not active_session_keys[key] then
		return nil
	end
	return drop.view(player_store, key)
end

return get_cached_player_data
