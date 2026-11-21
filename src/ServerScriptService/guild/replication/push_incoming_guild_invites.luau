const HttpService = game:GetService("HttpService")
const ReplicatedStorage = game:GetService("ReplicatedStorage")
const ServerScriptService = game:GetService("ServerScriptService")

const build_incoming_invites_snapshot = require(script.Parent.build_incoming_invites_snapshot)
const get_cached_player_data = require(ServerScriptService.player_data.get_cached_player_data)
const last_sent_guild_states = require(script.Parent.last_sent_guild_states)

const incoming_guild_invites_remote = ReplicatedStorage.remotes.guild.incoming_guild_invites

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
	incoming_guild_invites_remote:FireClient(player, invites)
end

return push_incoming_guild_invites
