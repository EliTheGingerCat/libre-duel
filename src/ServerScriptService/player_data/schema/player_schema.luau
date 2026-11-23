const ServerScriptService = game:GetService("ServerScriptService")

const drop = require(ServerScriptService.ServerPackages.drop)
const INITIAL_PLAYER_DATA = require(script.Parent.INITIAL_PLAYER_DATA)
const add_total_playtime = require(script.Parent.migrations.add_total_playtime)
const add_guild_fields = require(script.Parent.migrations.add_guild_fields)
const add_player_banners = require(script.Parent.migrations.add_player_banners)
const add_player_profile_fields = require(script.Parent.migrations.add_player_profile_fields)

-- always the output type of the last migration
export type player_data = add_player_profile_fields.with_player_profile_fields
export type rank_point = add_player_profile_fields.rank_point
export type player_stat = "total_clicks" | "playtime"

-- append only, never reorder or remove since saves store how many have run
const base_schema = drop.schema(INITIAL_PLAYER_DATA)
const schema_with_total_playtime = drop.migrate(base_schema, add_total_playtime)
const schema_with_player_banners = drop.migrate(schema_with_total_playtime, add_player_banners)
const schema_with_guild_fields = drop.migrate(schema_with_player_banners, add_guild_fields)
const player_schema = drop.migrate(schema_with_guild_fields, add_player_profile_fields)

return player_schema
