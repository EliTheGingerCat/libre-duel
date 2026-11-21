const ServerScriptService = game:GetService("ServerScriptService")

const get_player_guild = require(ServerScriptService.guild.membership.get_player_guild)
const remove_guild_member_async = require(ServerScriptService.guild.membership.remove_guild_member_async)

-- kicks them too, and stops them from being invited until they're unbanned
const function ban_guild_member(player: Player, target_user_id: number): string?
	const player_guild = get_player_guild(player)
	if player_guild == nil or not player_guild.is_owner then
		return "Only the guild owner can do that."
	end
	if target_user_id == player.UserId then
		return "You can't ban yourself."
	end
	return if remove_guild_member_async(player_guild.id, target_user_id, true)
		then nil
		else "Couldn't ban them, try again."
end

return ban_guild_member
