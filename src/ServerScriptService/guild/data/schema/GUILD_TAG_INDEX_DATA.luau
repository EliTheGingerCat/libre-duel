-- one record per lowercased tag, an empty guild_id means the tag is free
const GUILD_TAG_INDEX_DATA = {
	guild_id = "" :: string,
}

export type guild_tag_index_data = typeof(GUILD_TAG_INDEX_DATA)

return GUILD_TAG_INDEX_DATA
