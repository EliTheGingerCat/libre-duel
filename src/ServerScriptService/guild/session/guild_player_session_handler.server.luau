const Players = game:GetService("Players")
const ServerScriptService = game:GetService("ServerScriptService")

const drop = require(ServerScriptService.ServerPackages.drop)
const guild_playtime = require(ServerScriptService.guild.stats.guild_playtime)
const guild_schema = require(ServerScriptService.guild.data.schema.guild_schema)
const guild_store = require(ServerScriptService.guild.data.guild_store)
const last_sent_guild_states = require(ServerScriptService.guild.replication.last_sent_guild_states)
const on_session_stopping = require(ServerScriptService.player_data.session.on_session_stopping)
const player_guild_ids = require(script.Parent.player_guild_ids)
const player_schema = require(ServerScriptService.player_data.schema.player_schema)
const player_store = require(ServerScriptService.player_data.player_store)
const push_incoming_guild_invites = require(ServerScriptService.guild.replication.push_incoming_guild_invites)
const sync_player_guild = require(script.Parent.sync_player_guild)

-- fires when a player's session starts and on every refresh after, so it also picks up hint changes from other servers
const function on_player_data_changed(key: string, _data: player_schema.player_data): ()
	const user_id = tonumber(key)
	const player = if user_id then Players:GetPlayerByUserId(user_id) else nil
	if player == nil then
		return
	end
	push_incoming_guild_invites(player)
	sync_player_guild.sync_player_guild(player)
end

const function on_guild_data_changed(guild_id: string, _data: guild_schema.guild_data): ()
	for player, player_guild_id in player_guild_ids do
		if player_guild_id == guild_id then
			task.spawn(sync_player_guild.sync_player_guild, player)
		end
	end
end

const function on_player_removing(player: Player): ()
	sync_player_guild.stop_tracking(player)
	last_sent_guild_states.on_player_removing(player)
end

drop.observe(player_store, on_player_data_changed)
drop.observe(guild_store, on_guild_data_changed)
-- runs before the player's session stops, including on shutdown when PlayerRemoving may come too late
on_session_stopping(guild_playtime.stop)
Players.PlayerRemoving:Connect(on_player_removing)
