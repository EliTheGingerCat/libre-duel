const ReplicatedStorage = game:GetService("ReplicatedStorage")
const ServerScriptService = game:GetService("ServerScriptService")

const PLAYER_PROFILE_LIMITS = require(ReplicatedStorage.shared.player_profile.PLAYER_PROFILE_LIMITS)
const bind_action_remote = require(ServerScriptService.remotes.bind_action_remote)
const bind_query_remote = require(ServerScriptService.remotes.bind_query_remote)
const edit_player_bio = require(ServerScriptService.player_profile.actions.edit_player_bio)
const fetch_player_profile = require(ServerScriptService.player_profile.actions.fetch_player_profile)
const parse_user_id = require(ServerScriptService.remotes.parse_user_id)
const report_player = require(ServerScriptService.player_profile.report.report_player)
const request_player_banner_change = require(ServerScriptService.player_profile.actions.request_player_banner_change)

const player_profile_remotes = ReplicatedStorage.remotes.player_profile

const INVALID_REQUEST = "Invalid request."
const FETCH_PLAYER_PROFILE_COOLDOWN = 0.5
-- bytes, each character can be up to 4 of them
const MAX_BIO_BYTES = PLAYER_PROFILE_LIMITS.MAX_BIO_LENGTH * 4

const function run_fetch_player_profile(_player: Player, value: unknown): unknown
	const user_id = parse_user_id(value)
	return if user_id then fetch_player_profile(user_id) else nil
end

const function run_edit_player_bio(player: Player, value: unknown): string?
	if typeof(value) ~= "string" or #value > MAX_BIO_BYTES then
		return INVALID_REQUEST
	end
	return edit_player_bio(player, value)
end

const function run_report_player(player: Player, value: unknown): string?
	const user_id = parse_user_id(value)
	return if user_id then report_player(player, user_id) else INVALID_REQUEST
end

bind_query_remote(player_profile_remotes.fetch_player_profile, FETCH_PLAYER_PROFILE_COOLDOWN, run_fetch_player_profile)
bind_action_remote(player_profile_remotes.edit_player_bio, run_edit_player_bio)
bind_action_remote(player_profile_remotes.request_player_banner_change, request_player_banner_change)
bind_action_remote(player_profile_remotes.report_player, run_report_player)
