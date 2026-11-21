const ReplicatedStorage = game:GetService("ReplicatedStorage")

const format_incoming_invite = require(script.Parent.Parent.format.format_incoming_invite)
const guild_snapshot_types = require(ReplicatedStorage.shared.guild.guild_snapshot_types)
const guild_types = require(script.Parent.Parent.guild_types)
const use_user_info_version = require(ReplicatedStorage.client.guild.use_user_info_version)
const user_info_cache = require(ReplicatedStorage.client.guild.user_info_cache)

-- inviter names show as their user id until user_info_cache has them, then this rerenders
const function use_incoming_guild_invites(
	invites: { guild_snapshot_types.incoming_invite_snapshot }
): { guild_types.incoming_invite }
	use_user_info_version()
	const inviter_ids = {}
	for _, invite in invites do
		table.insert(inviter_ids, invite.inviter_id)
	end
	user_info_cache.request(inviter_ids)
	const formatted_invites = {}
	for _, invite in invites do
		table.insert(formatted_invites, format_incoming_invite(invite))
	end
	return formatted_invites
end

return use_incoming_guild_invites
