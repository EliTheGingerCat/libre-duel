const ReplicatedStorage = game:GetService("ReplicatedStorage")
const ServerScriptService = game:GetService("ServerScriptService")

const GAME_STATS = require(ReplicatedStorage.shared.modes.GAME_STATS)
const drop = require(ServerScriptService.ServerPackages.drop)

const player_schema = drop.schema({
	user_id = "" :: string, -- tostring(userid)

	first_joined = 0 :: number,
	total_clicks = 0 :: number,

	stats = { -- i hardcode this so data migration won't be a pain
		bridge_solo = {wins = 0, goals = 0, kills = 0, losses = 0, deaths = 0, playtime = 0},
		bridge_duos = {wins = 0, goals = 0, kills = 0, losses = 0, deaths = 0, playtime = 0},
	} :: GAME_STATS.modes
})

return player_schema
