const ReplicatedStorage = game:GetService("ReplicatedStorage")

const player_profile_snapshot_types = require(ReplicatedStorage.shared.player_profile.player_profile_snapshot_types)

const fetch_player_profile_remote = ReplicatedStorage.remotes.player_profile.fetch_player_profile

-- yields, nil when the server couldn't be reached, was rate limited or the player never played
const function fetch_player_profile(user_id: number): player_profile_snapshot_types.player_profile_snapshot?
	const ok, snapshot = pcall(fetch_player_profile_remote.InvokeServer, fetch_player_profile_remote, user_id)
	if not ok or typeof(snapshot) ~= "table" then
		return nil
	end
	return snapshot :: player_profile_snapshot_types.player_profile_snapshot
end

return fetch_player_profile
