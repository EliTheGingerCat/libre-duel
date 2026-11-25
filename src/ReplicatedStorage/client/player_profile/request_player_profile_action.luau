const ReplicatedStorage = game:GetService("ReplicatedStorage")

const zap_client_network = require(ReplicatedStorage.client.network.zap_client_network)

export type action_name = "edit_player_bio" | "request_player_banner_change" | "report_player"

export type action_result = zap_client_network.action_result

-- the argument types live in network.zap, zap errors before sending when a caller passes the wrong one
const PLAYER_PROFILE_ACTION_CALLS: { [action_name]: (argument: any) -> action_result } = {
	edit_player_bio = zap_client_network.edit_player_bio.call,
	request_player_banner_change = zap_client_network.request_player_banner_change.call,
	report_player = zap_client_network.report_player.call,
}

-- yields, the server already shows failures as a notification so callers only need ok
const function request_player_profile_action(name: action_name, argument: unknown?): action_result
	return PLAYER_PROFILE_ACTION_CALLS[name](argument)
end

return request_player_profile_action
