const ServerScriptService = game:GetService("ServerScriptService")

const PLAYER_STORE_NAME = require(ServerScriptService.player_data.PLAYER_STORE_NAME)
const bind_session_stopping_to_close = require(ServerScriptService.player_data.session.bind_session_stopping_to_close)
const drop = require(ServerScriptService.ServerPackages.drop)
const player_schema = require(ServerScriptService.player_data.schema.player_schema)

bind_session_stopping_to_close()

const player_store = drop.store({
	name = PLAYER_STORE_NAME,
	schema = player_schema,
})

return player_store
