const Players = game:GetService("Players")
const ReplicatedStorage = game:GetService("ReplicatedStorage")
const ServerScriptService = game:GetService("ServerScriptService")

const GUILD_LIMITS = require(ReplicatedStorage.shared.guild.GUILD_LIMITS)
const count_guild_members = require(ServerScriptService.guild.membership.count_guild_members)
const get_player_guild = require(ServerScriptService.guild.membership.get_player_guild)
const guild_schema = require(ServerScriptService.guild.data.schema.guild_schema)
const guild_store = require(ServerScriptService.guild.data.guild_store)
const player_schema = require(ServerScriptService.player_data.schema.player_schema)
const player_store = require(ServerScriptService.player_data.player_store)
const send_guild_invite_notification = require(script.Parent.send_guild_invite_notification)
const try_update_async = require(ServerScriptService.guild.data.try_update_async)

const function drop_oldest_invites(invites: { [string]: { invited_at: number } }): ()
	while true do
		local count = 0
		local oldest_id: string? = nil
		local oldest_time = math.huge
		for guild_id, invite in invites do
			count += 1
			if invite.invited_at < oldest_time then
				oldest_id = guild_id
				oldest_time = invite.invited_at
			end
		end
		if count <= GUILD_LIMITS.MAX_INCOMING_INVITES or oldest_id == nil then
			return
		end
		invites[oldest_id] = nil
	end
end

-- works for offline players and players in other servers since invites are saved in their data
const function invite_to_guild(player: Player, target_user_id: number): string?
	const player_guild = get_player_guild(player)
	if player_guild == nil or not player_guild.is_owner then
		return "Only the guild owner can do that."
	end
	const data = player_guild.data
	const target_key = tostring(target_user_id)
	if target_user_id == player.UserId or data.members[target_key] then
		return "They're already in your guild."
	end
	if data.banned[target_key] then
		return "They're banned from your guild, unban them first."
	end
	if data.outgoing_invites[target_key] then
		return "You already invited them."
	end
	if count_guild_members(data) >= GUILD_LIMITS.MAX_MEMBERS then
		return "Your guild is full."
	end

	const guild_id = player_guild.id
	const now = os.time()
	const function add_outgoing_invite(guild_data: guild_schema.guild_data): guild_schema.guild_data
		if guild_data.deleted or guild_data.members[target_key] or guild_data.banned[target_key] then
			error("can no longer invite")
		end
		const new_data = table.clone(guild_data)
		const new_invites = table.clone(guild_data.outgoing_invites)
		new_invites[target_key] = now
		new_data.outgoing_invites = new_invites
		return new_data
	end
	if not try_update_async(guild_store, guild_id, add_outgoing_invite) then
		return "Couldn't send the invite, try again."
	end

	const member_count = count_guild_members(data)
	const function add_incoming_invite(target_data: player_schema.player_data): player_schema.player_data
		const new_data = table.clone(target_data)
		-- saves that never went through a session can be missing migrated fields
		const new_invites = table.clone(target_data.incoming_guild_invites or {})
		new_invites[guild_id] = {
			invited_at = now,
			inviter_id = player.UserId,
			guild_name = data.name,
			guild_tag = data.tag,
			guild_icon = data.icon,
			guild_banner = data.banner,
			member_count = member_count,
		}
		drop_oldest_invites(new_invites)
		new_data.incoming_guild_invites = new_invites
		return new_data
	end
	if not try_update_async(player_store, target_key, add_incoming_invite) then
		const function remove_outgoing_invite(guild_data: guild_schema.guild_data): guild_schema.guild_data
			const new_data = table.clone(guild_data)
			const new_invites = table.clone(guild_data.outgoing_invites)
			new_invites[target_key] = nil
			new_data.outgoing_invites = new_invites
			return new_data
		end
		try_update_async(guild_store, guild_id, remove_outgoing_invite)
		return "Couldn't send the invite, try again."
	end

	const target = Players:GetPlayerByUserId(target_user_id)
	if target then
		send_guild_invite_notification(target, player, guild_id, data)
	end
	return nil
end

return invite_to_guild
