const ReplicatedStorage = game:GetService("ReplicatedStorage")
const ServerScriptService = game:GetService("ServerScriptService")

const accept_guild_invite = require(ServerScriptService.guild.actions.accept_guild_invite)
const ban_guild_member = require(ServerScriptService.guild.actions.ban_guild_member)
const bind_guild_action_remote = require(script.Parent.bind_guild_action_remote)
const bind_guild_query_remote = require(script.Parent.bind_guild_query_remote)
const cancel_guild_invite = require(ServerScriptService.guild.actions.cancel_guild_invite)
const create_guild = require(ServerScriptService.guild.actions.create_guild)
const decline_guild_invite = require(ServerScriptService.guild.actions.decline_guild_invite)
const edit_guild_info = require(ServerScriptService.guild.actions.edit_guild_info)
const fetch_guild_info = require(ServerScriptService.guild.actions.fetch_guild_info)
const invite_to_guild = require(ServerScriptService.guild.actions.invite_to_guild)
const kick_guild_member = require(ServerScriptService.guild.actions.kick_guild_member)
const leave_guild = require(ServerScriptService.guild.actions.leave_guild)
const parse_guild_remote_arguments = require(script.Parent.parse_guild_remote_arguments)
const request_guild_deletion = require(ServerScriptService.guild.actions.request_guild_deletion)
const search_guild_invite_candidate = require(ServerScriptService.guild.search.search_guild_invite_candidate)
const unban_guild_member = require(ServerScriptService.guild.actions.unban_guild_member)

const guild_remotes = ReplicatedStorage.remotes.guild

const INVALID_REQUEST = "Invalid request."
const SEARCH_COOLDOWN = 1
const FETCH_GUILD_INFO_COOLDOWN = 2

type target_action = (player: Player, target_user_id: number) -> string?
type guild_id_action = (player: Player, guild_id: string) -> string?

-- each wrapper turns the client's raw argument into what the action expects, or rejects it
const function with_user_id(action: target_action): (Player, unknown) -> string?
	const function run(player: Player, value: unknown): string?
		const user_id = parse_guild_remote_arguments.parse_user_id(value)
		return if user_id then action(player, user_id) else INVALID_REQUEST
	end
	return run
end

const function with_guild_id(action: guild_id_action): (Player, unknown) -> string?
	const function run(player: Player, value: unknown): string?
		const guild_id = parse_guild_remote_arguments.parse_guild_id(value)
		return if guild_id then action(player, guild_id) else INVALID_REQUEST
	end
	return run
end

const function run_create_guild(player: Player, value: unknown): string?
	const info = parse_guild_remote_arguments.parse_guild_info_input(value)
	return if info then create_guild(player, info) else INVALID_REQUEST
end

const function run_edit_guild_info(player: Player, value: unknown): string?
	const info = parse_guild_remote_arguments.parse_guild_info_input(value)
	return if info then edit_guild_info(player, info) else INVALID_REQUEST
end

const function run_search(_player: Player, value: unknown): unknown
	const query = parse_guild_remote_arguments.parse_short_string(value)
	return if query then search_guild_invite_candidate(query) else {}
end

const function run_fetch_guild_info(player: Player, value: unknown): unknown
	const guild_id = parse_guild_remote_arguments.parse_guild_id(value)
	return if guild_id then fetch_guild_info(player, guild_id) else nil
end

bind_guild_action_remote(guild_remotes.create_guild, run_create_guild)
bind_guild_action_remote(guild_remotes.edit_guild_info, run_edit_guild_info)
bind_guild_action_remote(guild_remotes.delete_guild, request_guild_deletion)
bind_guild_action_remote(guild_remotes.leave_guild, leave_guild)
bind_guild_action_remote(guild_remotes.invite_to_guild, with_user_id(invite_to_guild))
bind_guild_action_remote(guild_remotes.cancel_guild_invite, with_user_id(cancel_guild_invite))
bind_guild_action_remote(guild_remotes.kick_guild_member, with_user_id(kick_guild_member))
bind_guild_action_remote(guild_remotes.ban_guild_member, with_user_id(ban_guild_member))
bind_guild_action_remote(guild_remotes.unban_guild_member, with_user_id(unban_guild_member))
bind_guild_action_remote(guild_remotes.accept_guild_invite, with_guild_id(accept_guild_invite))
bind_guild_action_remote(guild_remotes.decline_guild_invite, with_guild_id(decline_guild_invite))
bind_guild_query_remote(guild_remotes.search_guild_invite_candidate, SEARCH_COOLDOWN, run_search)
bind_guild_query_remote(guild_remotes.fetch_guild_info, FETCH_GUILD_INFO_COOLDOWN, run_fetch_guild_info)
