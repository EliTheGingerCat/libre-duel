const ReplicatedStorage = game:GetService("ReplicatedStorage")

const GUILD_DEFAULT_ASSETS = require(ReplicatedStorage.shared.guild.GUILD_DEFAULT_ASSETS)
const guild_snapshot_types = require(ReplicatedStorage.shared.guild.guild_snapshot_types)
const guild_types = require(script.Parent.Parent.guild_types)
const user_info_cache = require(ReplicatedStorage.client.guild.user_info_cache)

-- request the inviter ids from user_info_cache first, the username shows as the id until it arrives
const function format_incoming_invite(
	invite: guild_snapshot_types.incoming_invite_snapshot
): guild_types.incoming_invite
	const inviter = user_info_cache.get(invite.inviter_id)
	return {
		guild_id = invite.guild_id,
		name = invite.guild_name,
		tag = invite.guild_tag,
		icon = if invite.guild_icon ~= "" then invite.guild_icon else GUILD_DEFAULT_ASSETS.icon,
		banner = if invite.guild_banner ~= "" then invite.guild_banner else GUILD_DEFAULT_ASSETS.banner,
		inviter_username = if inviter then inviter.username else tostring(invite.inviter_id),
		member_count = invite.member_count,
	}
end

return format_incoming_invite
