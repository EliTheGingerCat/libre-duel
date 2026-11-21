const remove_invite_from_both_sides = require(script.Parent.remove_invite_from_both_sides)

const function decline_guild_invite(player: Player, guild_id: string): string?
	return if remove_invite_from_both_sides(guild_id, player.UserId, false)
		then nil
		else "Couldn't decline the invite, try again."
end

return decline_guild_invite
