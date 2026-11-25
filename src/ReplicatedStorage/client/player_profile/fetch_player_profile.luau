const ReplicatedStorage = game:GetService("ReplicatedStorage")

const player_profile_snapshot_types = require(ReplicatedStorage.shared.player_profile.player_profile_snapshot_types)
const zap_client_network = require(ReplicatedStorage.client.network.zap_client_network)

-- yields, nil when rate limited or the player never played
const function fetch_player_profile(user_id: number): player_profile_snapshot_types.player_profile_snapshot?
	return zap_client_network.fetch_player_profile.call(user_id)
end

return fetch_player_profile
