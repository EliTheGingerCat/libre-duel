const ReplicatedStorage = game:GetService("ReplicatedStorage")

const player_row_types = require(script.Parent.Parent.Parent.player_row.player_row_types)
const user_info_cache = require(ReplicatedStorage.client.guild.user_info_cache)

-- names fall back to the user id until user_info_cache has fetched them
const function create_player_summary(user_id: number, banner: string): player_row_types.player_summary
	const info = user_info_cache.get(user_id)
	return {
		user_id = user_id,
		display_name = if info then info.display_name else tostring(user_id),
		username = if info then info.username else tostring(user_id),
		headshot = `rbxthumb://type=AvatarHeadShot&id={user_id}&w=150&h=150`,
		banner = banner,
	}
end

return create_player_summary
