const Players = game:GetService("Players")
const PolicyService = game:GetService("PolicyService")

local cached_result: boolean? = nil

-- Roblox only lets some players see references to Discord, everyone else must not be shown guild invites
-- yields the first time, false when the policy can't be read
const function can_see_discord_links(): boolean
	if cached_result ~= nil then
		return cached_result
	end
	const ok, policy = pcall(PolicyService.GetPolicyInfoForPlayerAsync, PolicyService, Players.LocalPlayer)
	if not ok then
		return false
	end
	const allowed = table.find(policy.AllowedExternalLinkReferences, "Discord") ~= nil
	cached_result = allowed
	return allowed
end

return can_see_discord_links
