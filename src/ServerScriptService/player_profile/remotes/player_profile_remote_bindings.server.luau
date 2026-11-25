const ReplicatedStorage = game:GetService("ReplicatedStorage")
const ServerScriptService = game:GetService("ServerScriptService")

const create_action_remote_handler = require(ServerScriptService.remotes.create_action_remote_handler)
const create_query_remote_handler = require(ServerScriptService.remotes.create_query_remote_handler)
const edit_player_bio = require(ServerScriptService.player_profile.actions.edit_player_bio)
const fetch_player_profile = require(ServerScriptService.player_profile.actions.fetch_player_profile)
const parse_user_id = require(ServerScriptService.remotes.parse_user_id)
const player_profile_snapshot_types = require(ReplicatedStorage.shared.player_profile.player_profile_snapshot_types)
const report_player = require(ServerScriptService.player_profile.report.report_player)
const request_player_banner_change = require(ServerScriptService.player_profile.actions.request_player_banner_change)
const zap_server_network = require(ServerScriptService.network.zap_server_network)

const INVALID_REQUEST = "Invalid request."
const FETCH_PLAYER_PROFILE_COOLDOWN = 0.5

const function run_fetch_player_profile(
	_player: Player,
	value: number
): player_profile_snapshot_types.player_profile_snapshot?
	const user_id = parse_user_id(value)
	return if user_id then fetch_player_profile(user_id) else nil
end

const function run_report_player(player: Player, value: number): string?
	const user_id = parse_user_id(value)
	return if user_id then report_player(player, user_id) else INVALID_REQUEST
end

zap_server_network.fetch_player_profile.set_callback(
	create_query_remote_handler("fetch_player_profile", FETCH_PLAYER_PROFILE_COOLDOWN, run_fetch_player_profile)
)
zap_server_network.edit_player_bio.set_callback(create_action_remote_handler("edit_player_bio", edit_player_bio))
zap_server_network.request_player_banner_change.set_callback(
	create_action_remote_handler("request_player_banner_change", request_player_banner_change)
)
zap_server_network.report_player.set_callback(create_action_remote_handler("report_player", run_report_player))
