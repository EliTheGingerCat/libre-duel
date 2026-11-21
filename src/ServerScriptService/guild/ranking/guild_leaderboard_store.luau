const DataStoreService = game:GetService("DataStoreService")

-- guild id -> get_guild_score
const guild_leaderboard_store = DataStoreService:GetOrderedDataStore("guild_scores")

return guild_leaderboard_store
