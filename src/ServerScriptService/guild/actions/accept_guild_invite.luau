const ReplicatedStorage = game:GetService("ReplicatedStorage")
const ServerScriptService = game:GetService("ServerScriptService")

const GUILD_LIMITS = require(ReplicatedStorage.shared.guild.GUILD_LIMITS)
const count_guild_members = require(ServerScriptService.guild.membership.count_guild_members)
const get_cached_player_data = require(ServerScriptService.player_data.get_cached_player_data)
const guild_schema = require(ServerScriptService.guild.data.schema.guild_schema)
const guild_session_refcount = require(ServerScriptService.guild.session.guild_session_refcount)
const guild_store = require(ServerScriptService.guild.data.guild_store)
const normalize_mode_stats = require(ServerScriptService.guild.data.normalize_mode_stats)
const player_schema = require(ServerScriptService.player_data.schema.player_schema)
const player_store = require(ServerScriptService.player_data.player_store)
const read_guild_data = require(ServerScriptService.guild.data.read_guild_data)
const remove_invite_from_both_sides = require(script.Parent.remove_invite_from_both_sides)
const run_guild_transaction = require(ServerScriptService.guild.data.run_guild_transaction)

-- nil when the guild can take this player right now
const function get_rejection_reason(data: guild_schema.guild_data?, user_key: string): string?
	if data == nil or data.deleted then
		return "That guild doesn't exist anymore."
	end
	if data.outgoing_invites[user_key] == nil or data.banned[user_key] then
		return "That invite expired."
	end
	if count_guild_members(data) >= GUILD_LIMITS.MAX_MEMBERS then
		return "That guild is full."
	end
	return nil
end

-- the transaction makes sure a player can't end up in two guilds or push one past the member cap
const function accept_guild_invite(player: Player, guild_id: string): string?
	const player_data = get_cached_player_data(player)
	if player_data == nil then
		return "Your data hasn't loaded yet."
	end
	if player_data.incoming_guild_invites == nil or player_data.incoming_guild_invites[guild_id] == nil then
		return "That invite expired."
	end
	if player_data.guild_id ~= "" then
		return "Leave your current guild first."
	end
	const user_key = tostring(player.UserId)
	const rejection = get_rejection_reason(read_guild_data(guild_id), user_key)
	if rejection then
		remove_invite_from_both_sides(guild_id, player.UserId, false)
		return rejection
	end

	const now = os.time()
	const banner = player_data.player_banner_id
	const function join_in_player_data(data: player_schema.player_data): player_schema.player_data
		if data.guild_id ~= "" then
			error("already in a guild")
		end
		const new_data = table.clone(data)
		const new_invites = table.clone(data.incoming_guild_invites)
		new_invites[guild_id] = nil
		new_data.incoming_guild_invites = new_invites
		new_data.guild_id = guild_id
		return new_data
	end
	const function join_in_guild(data: guild_schema.guild_data): guild_schema.guild_data
		const reason = get_rejection_reason(data, user_key)
		if reason then
			error(reason)
		end
		const new_data = table.clone(data)
		const new_members = table.clone(data.members)
		new_members[user_key] = { joined = now, banner = banner, playtime = 0, stats = normalize_mode_stats(nil) }
		new_data.members = new_members
		const new_invites = table.clone(data.outgoing_invites)
		new_invites[user_key] = nil
		new_data.outgoing_invites = new_invites
		return new_data
	end
	const joined = run_guild_transaction({
		{ store = player_store, key = user_key, transform = join_in_player_data, refresh_after = true },
		{
			store = guild_store,
			key = guild_id,
			transform = join_in_guild,
			refresh_after = guild_session_refcount.is_active(guild_id),
		},
	})
	return if joined then nil else "Couldn't join the guild, try again."
end

return accept_guild_invite
