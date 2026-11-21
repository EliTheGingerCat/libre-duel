const ServerScriptService = game:GetService("ServerScriptService")

const guild_schema = require(ServerScriptService.guild.data.schema.guild_schema)
const guild_store = require(ServerScriptService.guild.data.guild_store)
const player_schema = require(ServerScriptService.player_data.schema.player_schema)
const player_store = require(ServerScriptService.player_data.player_store)
const try_update_async = require(ServerScriptService.guild.data.try_update_async)

-- for cancelling and declining, true when the side that asked for it got updated
-- the other side is best effort since a stale invite just fails when accepted
const function remove_invite_from_both_sides(guild_id: string, user_id: number, guild_side_first: boolean): boolean
	const user_key = tostring(user_id)
	const function remove_outgoing(data: guild_schema.guild_data): guild_schema.guild_data
		if data.outgoing_invites[user_key] == nil then
			return data
		end
		const new_data = table.clone(data)
		const new_invites = table.clone(data.outgoing_invites)
		new_invites[user_key] = nil
		new_data.outgoing_invites = new_invites
		return new_data
	end
	const function remove_incoming(data: player_schema.player_data): player_schema.player_data
		-- saves that never went through a session can be missing migrated fields
		if data.incoming_guild_invites == nil or data.incoming_guild_invites[guild_id] == nil then
			return data
		end
		const new_data = table.clone(data)
		const new_invites = table.clone(data.incoming_guild_invites)
		new_invites[guild_id] = nil
		new_data.incoming_guild_invites = new_invites
		return new_data
	end
	if guild_side_first then
		const ok = try_update_async(guild_store, guild_id, remove_outgoing)
		try_update_async(player_store, user_key, remove_incoming)
		return ok
	end
	const ok = try_update_async(player_store, user_key, remove_incoming)
	try_update_async(guild_store, guild_id, remove_outgoing)
	return ok
end

return remove_invite_from_both_sides
