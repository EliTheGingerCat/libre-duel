const ReplicatedStorage = game:GetService("ReplicatedStorage")

export type action_name =
	"create_guild"
	| "edit_guild_info"
	| "delete_guild"
	| "request_guild_image_change"
	| "leave_guild"
	| "invite_to_guild"
	| "cancel_guild_invite"
	| "kick_guild_member"
	| "ban_guild_member"
	| "unban_guild_member"
	| "accept_guild_invite"
	| "decline_guild_invite"

export type action_result = { ok: boolean, error: string? }

const guild_remotes = ReplicatedStorage.remotes.guild

-- yields, the server already shows failures as a notification so callers only need ok
const function request_guild_action(name: action_name, argument: unknown?): action_result
	const remote = guild_remotes:FindFirstChild(name) :: RemoteFunction
	const ok, result = pcall(remote.InvokeServer, remote, argument)
	if not ok or typeof(result) ~= "table" then
		return { ok = false, error = "Couldn't reach the server." }
	end
	return result :: action_result
end

return request_guild_action
