const Players = game:GetService("Players")
const ReplicatedStorage = game:GetService("ReplicatedStorage")

const PLAYER_BANNER_ATTRIBUTE = require(ReplicatedStorage.shared.player_profile.PLAYER_BANNER_ATTRIBUTE)
const player_row_types = require(script.Parent.player_row_types)
const user_info_cache = require(ReplicatedStorage.client.guild.user_info_cache)

-- players in this server have their banner on an attribute, which is newer than any copy that came with other data
const function get_banner(user_id: number, fallback_banner: string): string
	const player = Players:GetPlayerByUserId(user_id)
	const attribute_banner = if player then player:GetAttribute(PLAYER_BANNER_ATTRIBUTE) else nil
	if typeof(attribute_banner) == "string" and attribute_banner ~= "" then
		return attribute_banner
	end
	return fallback_banner
end

-- names fall back to the user id until user_info_cache has fetched them
const function create_player_summary(user_id: number, banner: string): player_row_types.player_summary
	const info = user_info_cache.get(user_id)
	return {
		user_id = user_id,
		display_name = if info then info.display_name else tostring(user_id),
		username = if info then info.username else tostring(user_id),
		headshot = `rbxthumb://type=AvatarHeadShot&id={user_id}&w=150&h=150`,
		banner = get_banner(user_id, banner),
	}
end

return create_player_summary
