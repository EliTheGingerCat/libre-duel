const HttpService = game:GetService("HttpService")
const ServerScriptService = game:GetService("ServerScriptService")

const build_guild_snapshot = require(script.Parent.build_guild_snapshot)
const get_player_guild = require(ServerScriptService.guild.membership.get_player_guild)
const last_sent_guild_states = require(script.Parent.last_sent_guild_states)
const zap_server_network = require(ServerScriptService.network.zap_server_network)

-- sends the player their guild, or nil when they have none, skipping it when nothing changed
const function push_guild_state(player: Player): ()
	const player_guild = get_player_guild(player)
	const snapshot = if player_guild then build_guild_snapshot(player_guild.data, true) else nil
	const encoded = if snapshot then HttpService:JSONEncode(snapshot) else ""
	if last_sent_guild_states.guild_states[player] == encoded then
		return
	end
	last_sent_guild_states.guild_states[player] = encoded
	zap_server_network.guild_state.fire(player, snapshot)
end

return push_guild_state
