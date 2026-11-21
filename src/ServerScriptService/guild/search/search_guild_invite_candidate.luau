const Players = game:GetService("Players")
const ReplicatedStorage = game:GetService("ReplicatedStorage")
const UserService = game:GetService("UserService")

const guild_snapshot_types = require(ReplicatedStorage.shared.guild.guild_snapshot_types)

-- roblox usernames are 3 to 20 letters, digits and underscores
const USERNAME_PATTERN = "^[%w_]+$"
const MIN_USERNAME_LENGTH = 3
const MAX_USERNAME_LENGTH = 20

-- exact username lookup, roblox has no fuzzy user search we can call from a game
const function search_guild_invite_candidate(query: string): { guild_snapshot_types.player_search_result }
	if #query < MIN_USERNAME_LENGTH or #query > MAX_USERNAME_LENGTH or string.match(query, USERNAME_PATTERN) == nil then
		return {}
	end
	const id_ok, user_id = pcall(Players.GetUserIdFromNameAsync, Players, query)
	if not id_ok then
		return {}
	end
	const info_ok, infos = pcall(UserService.GetUserInfosByUserIdsAsync, UserService, { user_id })
	if not info_ok or infos[1] == nil then
		return {}
	end
	return { { user_id = user_id, username = infos[1].Username, display_name = infos[1].DisplayName } }
end

return search_guild_invite_candidate
