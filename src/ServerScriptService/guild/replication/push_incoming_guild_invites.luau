const HttpService = game:GetService("HttpService")
const ServerScriptService = game:GetService("ServerScriptService")

const build_incoming_invites_snapshot = require(script.Parent.build_incoming_invites_snapshot)
const get_cached_player_data = require(ServerScriptService.player_data.get_cached_player_data)
const last_sent_guild_states = require(script.Parent.last_sent_guild_states)
const zap_server_network = require(ServerScriptService.network.zap_server_network)

const function push_incoming_guild_invites(player: Player): ()
	const data = get_cached_player_data(player)
	if data == nil then
		return
	end
	const invites = build_incoming_invites_snapshot(data)
	const encoded = HttpService:JSONEncode(invites)
	if last_sent_guild_states.incoming_invites[player] == encoded then
		return
	end
	last_sent_guild_states.incoming_invites[player] = encoded
	zap_server_network.incoming_guild_invites.fire(player, invites)
end

return push_incoming_guild_invites
