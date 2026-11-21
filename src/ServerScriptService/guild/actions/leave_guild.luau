const ServerScriptService = game:GetService("ServerScriptService")

const get_player_guild = require(ServerScriptService.guild.membership.get_player_guild)
const remove_guild_member_async = require(ServerScriptService.guild.membership.remove_guild_member_async)

const function leave_guild(player: Player): string?
	const player_guild = get_player_guild(player)
	if player_guild == nil then
		return "You're not in a guild."
	end
	if player_guild.is_owner then
		return "Owners can't leave, delete the guild instead."
	end
	return if remove_guild_member_async(player_guild.id, player.UserId, false)
		then nil
		else "Couldn't leave the guild, try again."
end

return leave_guild
