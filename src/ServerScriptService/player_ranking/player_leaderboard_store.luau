const DataStoreService = game:GetService("DataStoreService")

-- tostring(userid) -> get_player_score
-- switching what players are ranked by means a new store name, old scores can't be reinterpreted in place
const player_leaderboard_store = DataStoreService:GetOrderedDataStore("player_scores")

return player_leaderboard_store
