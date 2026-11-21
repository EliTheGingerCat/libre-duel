const PLACEHOLDER_ASSETS = require(script.Parent.PLACEHOLDER_ASSETS)
const guild_types = require(script.Parent.Parent.guild.guild_types)

const PLACEHOLDER_INCOMING_INVITES: { guild_types.incoming_invite } = {
	{
		guild_id = "00000000-0000-0000-0000-000000000000",
		name = "The Ok Association",
		tag = "TOA",
		icon = PLACEHOLDER_ASSETS.headshot,
		banner = PLACEHOLDER_ASSETS.profile_banner,
		inviter_username = "breter98",
		member_count = 12,
	},
}

return PLACEHOLDER_INCOMING_INVITES
