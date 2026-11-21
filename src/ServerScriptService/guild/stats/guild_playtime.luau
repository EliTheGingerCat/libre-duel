const ServerScriptService = game:GetService("ServerScriptService")

const drop = require(ServerScriptService.ServerPackages.drop)
const guild_schema = require(ServerScriptService.guild.data.schema.guild_schema)
const guild_session_refcount = require(ServerScriptService.guild.session.guild_session_refcount)
const guild_store = require(ServerScriptService.guild.data.guild_store)

type tracked_playtime = { guild_id: string, started: number }

-- when each player started counting playtime for their current guild on this server
const tracked_playtimes: { [Player]: tracked_playtime } = {}

const function start(player: Player, guild_id: string): ()
	tracked_playtimes[player] = { guild_id = guild_id, started = os.time() }
end

-- never yields so it is safe inside session stopping callbacks, needs the guild session to still be active
const function stop(player: Player): ()
	const tracked = tracked_playtimes[player]
	tracked_playtimes[player] = nil
	if tracked == nil or not guild_session_refcount.is_active(tracked.guild_id) then
		return
	end
	const seconds = os.time() - tracked.started
	if seconds <= 0 then
		return
	end
	const user_id = tostring(player.UserId)
	const function add_playtime(data: guild_schema.guild_data): guild_schema.guild_data
		const member = data.members[user_id]
		if member == nil then
			return data
		end
		const new_data = table.clone(data)
		const new_members = table.clone(data.members)
		const new_member = table.clone(member)
		new_member.playtime += seconds
		new_members[user_id] = new_member
		new_data.members = new_members
		new_data.total_playtime += seconds
		return new_data
	end
	drop.update(guild_store, tracked.guild_id, add_playtime)
end

return {
	start = start,
	stop = stop,
}
