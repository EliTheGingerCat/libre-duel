const ServerScriptService = game:GetService("ServerScriptService")

const GUILD_TAG_INDEX_DATA = require(script.Parent.schema.GUILD_TAG_INDEX_DATA)
const drop = require(ServerScriptService.ServerPackages.drop)

-- keyed by string.lower(tag), only ever touched inside transactions so two guilds can't claim one tag
const guild_tag_store = drop.store({
	name = "guild_tags",
	schema = drop.schema(GUILD_TAG_INDEX_DATA),
})

return guild_tag_store
