const ServerScriptService = game:GetService("ServerScriptService")

const get_player_guild = require(ServerScriptService.guild.membership.get_player_guild)
const remove_invite_from_both_sides = require(script.Parent.remove_invite_from_both_sides)

const function cancel_guild_invite(player: Player, target_user_id: number): string?
	const player_guild = get_player_guild(player)
	if player_guild == nil or not player_guild.is_owner then
		return "Only the guild owner can do that."
	end
	if player_guild.data.outgoing_invites[tostring(target_user_id)] == nil then
		return nil
	end
	return if remove_invite_from_both_sides(player_guild.id, target_user_id, true)
		then nil
		else "Couldn't cancel the invite, try again."
end

return cancel_guild_invite
