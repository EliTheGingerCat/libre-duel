const GUILD_LIMITS = {
	MAX_MEMBERS = 50,
	MAX_NAME_LENGTH = 50,
	MIN_TAG_LENGTH = 2,
	MAX_TAG_LENGTH = 7,
	MAX_DESCRIPTION_LENGTH = 10000,
	MAX_DISCORD_INVITE_LENGTH = 64,
	-- oldest invites get dropped past this so a player can't be flooded
	MAX_INCOMING_INVITES = 20,
	MAX_RANK_HISTORY_POINTS = 30,
	-- guilds below this rank show as unranked, OrderedDataStore can't tell us more without paging forever
	MAX_TRACKED_RANK = 1000,
	TAG_PATTERN = "^%w+$",
}

return GUILD_LIMITS
