const ServerScriptService = game:GetService("ServerScriptService")

const INITIAL_GUILD_DATA = require(script.Parent.INITIAL_GUILD_DATA)
const drop = require(ServerScriptService.ServerPackages.drop)

-- always the output type of the last migration
export type guild_data = INITIAL_GUILD_DATA.guild_data
export type guild_member = INITIAL_GUILD_DATA.guild_member
export type rank_point = INITIAL_GUILD_DATA.rank_point

-- append only, never reorder or remove since saves store how many have run
const guild_schema = drop.schema(INITIAL_GUILD_DATA)

return guild_schema
