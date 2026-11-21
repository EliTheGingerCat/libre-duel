const ServerScriptService = game:GetService("ServerScriptService")

const drop = require(ServerScriptService.ServerPackages.drop)
const guild_schema = require(script.Parent.schema.guild_schema)

-- keyed by guild id, many servers can hold a session on the same guild since drop merges queued updates
const guild_store = drop.store({
	name = "guilds",
	schema = guild_schema,
})

return guild_store
