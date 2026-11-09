const ServerScriptService = game:GetService("ServerScriptService")
const PLAYER_STORE_NAME = require(ServerScriptService.player_data.PLAYER_STORE_NAME)
const drop = require(ServerScriptService.ServerPackages.drop)
const player_schema = require(ServerScriptService.player_data.player_schema)

const player_store = drop.store({
	name = PLAYER_STORE_NAME,
	schema = player_schema,
})

return player_store
