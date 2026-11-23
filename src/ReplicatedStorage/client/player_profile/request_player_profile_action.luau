const ReplicatedStorage = game:GetService("ReplicatedStorage")

export type action_name = "edit_player_bio" | "request_player_banner_change" | "report_player"

export type action_result = { ok: boolean, error: string? }

const player_profile_remotes = ReplicatedStorage.remotes.player_profile

-- yields, the server already shows failures as a notification so callers only need ok
const function request_player_profile_action(name: action_name, argument: unknown?): action_result
	const remote = player_profile_remotes:FindFirstChild(name) :: RemoteFunction
	const ok, result = pcall(remote.InvokeServer, remote, argument)
	if not ok or typeof(result) ~= "table" then
		return { ok = false, error = "Couldn't reach the server." }
	end
	return result :: action_result
end

return request_player_profile_action
