const PLAYER_PROFILE_LIMITS = {
	MAX_BIO_LENGTH = 2000,
	MAX_RANK_HISTORY_POINTS = 30,
	-- players below this rank show as unranked, OrderedDataStore can't tell us more without paging forever
	MAX_TRACKED_RANK = 1000,
	-- seconds between last_online bumps while a player is in a server
	LAST_ONLINE_INTERVAL = 60,
}

return PLAYER_PROFILE_LIMITS
