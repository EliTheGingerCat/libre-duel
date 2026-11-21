const ReplicatedStorage = game:GetService("ReplicatedStorage")
const ServerScriptService = game:GetService("ServerScriptService")

const guild_snapshot_types = require(ReplicatedStorage.shared.guild.guild_snapshot_types)
const add_guild_fields = require(ServerScriptService.player_data.schema.migrations.add_guild_fields)
const player_schema = require(ServerScriptService.player_data.schema.player_schema)

const function compare_invites(
	first: guild_snapshot_types.incoming_invite_snapshot,
	second: guild_snapshot_types.incoming_invite_snapshot
): boolean
	return first.invited_at > second.invited_at
end

-- newest first
const function build_incoming_invites_snapshot(
	data: player_schema.player_data
): { guild_snapshot_types.incoming_invite_snapshot }
	const invites = {}
	-- saves that never went through a session can be missing migrated fields
	const invites_by_guild: { [string]: add_guild_fields.incoming_guild_invite } = data.incoming_guild_invites or {}
	for guild_id, invite in invites_by_guild do
		table.insert(invites, {
			guild_id = guild_id,
			guild_name = invite.guild_name,
			guild_tag = invite.guild_tag,
			guild_icon = invite.guild_icon,
			guild_banner = invite.guild_banner,
			member_count = invite.member_count,
			inviter_id = invite.inviter_id,
			invited_at = invite.invited_at,
		})
	end
	table.sort(invites, compare_invites)
	return invites
end

return build_incoming_invites_snapshot
