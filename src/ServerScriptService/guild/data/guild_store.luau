const ServerScriptService = game:GetService("ServerScriptService")

const drop = require(ServerScriptService.ServerPackages.drop)
const guild_schema = require(script.Parent.schema.guild_schema)
-- player data has to bind its BindToClose first, so its session stopping callbacks can still queue guild updates
require(ServerScriptService.player_data.player_store)

-- keyed by guild id, many servers can hold a session on the same guild since drop merges queued updates
const guild_store = drop.store({
	name = "guilds",
	schema = guild_schema,
})

return guild_store
