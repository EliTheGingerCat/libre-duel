const ServerScriptService = game:GetService("ServerScriptService")

const get_player_guild = require(ServerScriptService.guild.membership.get_player_guild)
const guild_schema = require(ServerScriptService.guild.data.schema.guild_schema)
const guild_store = require(ServerScriptService.guild.data.guild_store)
const try_update_async = require(ServerScriptService.guild.data.try_update_async)

const function unban_guild_member(player: Player, target_user_id: number): string?
	const player_guild = get_player_guild(player)
	if player_guild == nil or not player_guild.is_owner then
		return "Only the guild owner can do that."
	end
	const target_key = tostring(target_user_id)
	const function remove_ban(data: guild_schema.guild_data): guild_schema.guild_data
		if data.banned[target_key] == nil then
			return data
		end
		const new_data = table.clone(data)
		const new_banned = table.clone(data.banned)
		new_banned[target_key] = nil
		new_data.banned = new_banned
		return new_data
	end
	return if try_update_async(guild_store, player_guild.id, remove_ban) then nil else "Couldn't unban them, try again."
end

return unban_guild_member
