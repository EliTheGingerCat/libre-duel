const ServerScriptService = game:GetService("ServerScriptService")

const add_player_banners = require(ServerScriptService.player_data.schema.migrations.add_player_banners)

export type incoming_guild_invite = {
	invited_at: number,
	inviter_id: number,
	-- copied when the invite is sent so the invitee can see it without loading the guild
	guild_name: string,
	guild_tag: string,
	guild_icon: string,
	guild_banner: string,
	member_count: number,
}

export type with_guild_fields = add_player_banners.with_player_banner & {
	-- only a hint, the guild's member list is the source of truth and the hint gets cleared when they disagree
	guild_id: string, -- "" when not in a guild
	incoming_guild_invites: { [string]: incoming_guild_invite }, -- guild id -> invite
}

const function add_guild_fields(data: add_player_banners.with_player_banner): with_guild_fields
	const new_data = table.clone(data) :: with_guild_fields
	new_data.guild_id = ""
	new_data.incoming_guild_invites = {}
	return new_data
end

return add_guild_fields
