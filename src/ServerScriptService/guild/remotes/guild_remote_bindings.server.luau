const ReplicatedStorage = game:GetService("ReplicatedStorage")
const ServerScriptService = game:GetService("ServerScriptService")

const accept_guild_invite = require(ServerScriptService.guild.actions.accept_guild_invite)
const ban_guild_member = require(ServerScriptService.guild.actions.ban_guild_member)
const cancel_guild_invite = require(ServerScriptService.guild.actions.cancel_guild_invite)
const create_action_remote_handler = require(ServerScriptService.remotes.create_action_remote_handler)
const create_guild = require(ServerScriptService.guild.actions.create_guild)
const create_query_remote_handler = require(ServerScriptService.remotes.create_query_remote_handler)
const decline_guild_invite = require(ServerScriptService.guild.actions.decline_guild_invite)
const edit_guild_info = require(ServerScriptService.guild.actions.edit_guild_info)
const fetch_guild_info = require(ServerScriptService.guild.actions.fetch_guild_info)
const guild_snapshot_types = require(ReplicatedStorage.shared.guild.guild_snapshot_types)
const invite_to_guild = require(ServerScriptService.guild.actions.invite_to_guild)
const kick_guild_member = require(ServerScriptService.guild.actions.kick_guild_member)
const leave_guild = require(ServerScriptService.guild.actions.leave_guild)
const parse_guild_id = require(script.Parent.parse_guild_id)
const parse_user_id = require(ServerScriptService.remotes.parse_user_id)
const request_guild_deletion = require(ServerScriptService.guild.actions.request_guild_deletion)
const request_guild_image_change = require(ServerScriptService.guild.actions.request_guild_image_change)
const search_guild_invite_candidate = require(ServerScriptService.guild.search.search_guild_invite_candidate)
const unban_guild_member = require(ServerScriptService.guild.actions.unban_guild_member)
const zap_server_network = require(ServerScriptService.network.zap_server_network)

const INVALID_REQUEST = "Invalid request."
const SEARCH_COOLDOWN = 1
const FETCH_GUILD_INFO_COOLDOWN = 2

type target_action = (player: Player, target_user_id: number) -> string?
type guild_id_action = (player: Player, guild_id: string) -> string?

-- zap already checked the types, these wrappers check the values
const function with_user_id(action: target_action): (Player, number) -> string?
	const function run(player: Player, value: number): string?
		const user_id = parse_user_id(value)
		return if user_id then action(player, user_id) else INVALID_REQUEST
	end
	return run
end

const function with_guild_id(action: guild_id_action): (Player, string) -> string?
	const function run(player: Player, value: string): string?
		const guild_id = parse_guild_id(value)
		return if guild_id then action(player, guild_id) else INVALID_REQUEST
	end
	return run
end

const function run_search(_player: Player, query: string): { guild_snapshot_types.player_search_result }
	return search_guild_invite_candidate(query)
end

const function run_fetch_guild_info(player: Player, value: string): guild_snapshot_types.guild_snapshot?
	const guild_id = parse_guild_id(value)
	return if guild_id then fetch_guild_info(player, guild_id) else nil
end

zap_server_network.create_guild.set_callback(create_action_remote_handler("create_guild", create_guild))
zap_server_network.edit_guild_info.set_callback(create_action_remote_handler("edit_guild_info", edit_guild_info))
zap_server_network.delete_guild.set_callback(create_action_remote_handler("delete_guild", request_guild_deletion))
zap_server_network.request_guild_image_change.set_callback(
	create_action_remote_handler("request_guild_image_change", request_guild_image_change)
)
zap_server_network.leave_guild.set_callback(create_action_remote_handler("leave_guild", leave_guild))
zap_server_network.invite_to_guild.set_callback(
	create_action_remote_handler("invite_to_guild", with_user_id(invite_to_guild))
)
zap_server_network.cancel_guild_invite.set_callback(
	create_action_remote_handler("cancel_guild_invite", with_user_id(cancel_guild_invite))
)
zap_server_network.kick_guild_member.set_callback(
	create_action_remote_handler("kick_guild_member", with_user_id(kick_guild_member))
)
zap_server_network.ban_guild_member.set_callback(
	create_action_remote_handler("ban_guild_member", with_user_id(ban_guild_member))
)
zap_server_network.unban_guild_member.set_callback(
	create_action_remote_handler("unban_guild_member", with_user_id(unban_guild_member))
)
zap_server_network.accept_guild_invite.set_callback(
	create_action_remote_handler("accept_guild_invite", with_guild_id(accept_guild_invite))
)
zap_server_network.decline_guild_invite.set_callback(
	create_action_remote_handler("decline_guild_invite", with_guild_id(decline_guild_invite))
)
zap_server_network.search_guild_invite_candidate.set_callback(
	create_query_remote_handler("search_guild_invite_candidate", SEARCH_COOLDOWN, run_search)
)
zap_server_network.fetch_guild_info.set_callback(
	create_query_remote_handler("fetch_guild_info", FETCH_GUILD_INFO_COOLDOWN, run_fetch_guild_info)
)
