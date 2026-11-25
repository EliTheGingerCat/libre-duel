const ReplicatedStorage = game:GetService("ReplicatedStorage")

const zap_client_network = require(ReplicatedStorage.client.network.zap_client_network)

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

export type action_result = zap_client_network.action_result

-- the argument types live in network.zap, zap errors before sending when a caller passes the wrong one
const GUILD_ACTION_CALLS: { [action_name]: (argument: any) -> action_result } = {
	create_guild = zap_client_network.create_guild.call,
	edit_guild_info = zap_client_network.edit_guild_info.call,
	delete_guild = zap_client_network.delete_guild.call,
	request_guild_image_change = zap_client_network.request_guild_image_change.call,
	leave_guild = zap_client_network.leave_guild.call,
	invite_to_guild = zap_client_network.invite_to_guild.call,
	cancel_guild_invite = zap_client_network.cancel_guild_invite.call,
	kick_guild_member = zap_client_network.kick_guild_member.call,
	ban_guild_member = zap_client_network.ban_guild_member.call,
	unban_guild_member = zap_client_network.unban_guild_member.call,
	accept_guild_invite = zap_client_network.accept_guild_invite.call,
	decline_guild_invite = zap_client_network.decline_guild_invite.call,
}

-- yields, the server already shows failures as a notification so callers only need ok
const function request_guild_action(name: action_name, argument: unknown?): action_result
	return GUILD_ACTION_CALLS[name](argument)
end

return request_guild_action
