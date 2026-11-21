const ServerScriptService = game:GetService("ServerScriptService")

const dirty_guild_scores = require(ServerScriptService.guild.ranking.dirty_guild_scores)
const drop = require(ServerScriptService.ServerPackages.drop)
const get_cached_player_data = require(ServerScriptService.player_data.get_cached_player_data)
const guild_playtime = require(ServerScriptService.guild.stats.guild_playtime)
const guild_schema = require(ServerScriptService.guild.data.schema.guild_schema)
const guild_session_refcount = require(script.Parent.guild_session_refcount)
const guild_store = require(ServerScriptService.guild.data.guild_store)
const player_guild_ids = require(script.Parent.player_guild_ids)
const player_schema = require(ServerScriptService.player_data.schema.player_schema)
const player_store = require(ServerScriptService.player_data.player_store)
const push_guild_state = require(ServerScriptService.guild.replication.push_guild_state)

-- players mid sync, true when another sync was requested while it ran
const syncing_players: { [Player]: boolean } = {}

const function stop_tracking(player: Player): ()
	const guild_id = player_guild_ids[player]
	if guild_id == nil then
		return
	end
	guild_playtime.stop(player)
	player_guild_ids[player] = nil
	guild_session_refcount.release(guild_id)
end

const function clear_guild_hint(player: Player, stale_guild_id: string): ()
	const function clear_hint(data: player_schema.player_data): player_schema.player_data
		if data.guild_id ~= stale_guild_id then
			return data
		end
		const new_data = table.clone(data)
		new_data.guild_id = ""
		return new_data
	end
	drop.update(player_store, tostring(player.UserId), clear_hint)
end

const function copy_banner_to_member(player: Player, guild_id: string, banner: string): ()
	const user_id = tostring(player.UserId)
	const function set_banner(data: guild_schema.guild_data): guild_schema.guild_data
		const member = data.members[user_id]
		if member == nil or member.banner == banner then
			return data
		end
		const new_data = table.clone(data)
		const new_members = table.clone(data.members)
		const new_member = table.clone(member)
		new_member.banner = banner
		new_members[user_id] = new_member
		new_data.members = new_members
		return new_data
	end
	drop.update(guild_store, guild_id, set_banner)
end

const function sync_once(player: Player): ()
	const player_data = get_cached_player_data(player)
	if player_data == nil then
		return
	end
	-- saves that never went through a session can be missing migrated fields
	const hint = player_data.guild_id or ""
	if player_guild_ids[player] ~= hint then
		stop_tracking(player)
		if hint ~= "" and guild_session_refcount.acquire(hint) then
			if player.Parent == nil then
				guild_session_refcount.release(hint)
				return
			end
			player_guild_ids[player] = hint
			guild_playtime.start(player, hint)
			-- new guilds and guilds without wins have no leaderboard entry yet, and without one they never get a rank
			dirty_guild_scores[hint] = true
		end
	end

	const guild_id = player_guild_ids[player]
	if guild_id ~= nil then
		const guild_data = drop.view(guild_store, guild_id)
		const member = guild_data.members[tostring(player.UserId)]
		if guild_data.deleted or member == nil then
			stop_tracking(player)
			clear_guild_hint(player, guild_id)
		elseif member.banner ~= player_data.player_banner_id then
			copy_banner_to_member(player, guild_id, player_data.player_banner_id)
		end
	end
	push_guild_state(player)
end

-- makes this server's view of the player's guild match their data, can yield while a guild session starts
-- the hint is cleared when the guild disagrees, which is how kicks and deletions reach offline players
const function sync_player_guild(player: Player): ()
	if syncing_players[player] ~= nil then
		syncing_players[player] = true
		return
	end
	const function on_error(message: unknown)
		warn(`Guild sync failed for {player.UserId}: {message}`)
	end
	repeat
		syncing_players[player] = false
		xpcall(sync_once, on_error, player)
	until syncing_players[player] ~= true or player.Parent == nil
	syncing_players[player] = nil
end

return {
	sync_player_guild = sync_player_guild,
	stop_tracking = stop_tracking,
}
