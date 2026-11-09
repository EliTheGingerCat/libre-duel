-- **WORK IN PROGRESS** while i finish player data stuff
-- but this is a good starting schema I think
-- if anyone submitted a pr to implement guilds i wouldn't mind heh...

const ServerScriptService = game:GetService("ServerScriptService")
const ReplicatedStorage = game:GetService("ReplicatedStorage")

const GAME_STATS = require(ReplicatedStorage.shared.modes.GAME_STATS)
const drop = require(ServerScriptService.ServerPackages.drop)

const guild_schema = drop.schema({
	id = "" :: string, -- this will be a GUID and also should NEVER be changed

	name = "" :: string,
	description = "" :: string,
	icon = 0 :: number,
	banner = 0 :: number,

	members = {} :: {
		[string]: { -- tostring(userid)
			joined: number, -- unix time
			-- TODO: still not sure how to figure out migration since these are created in runtime!!
			stats: GAME_STATS.modes
		},
	},
})

return guild_schema
