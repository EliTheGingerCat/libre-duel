const GUILD_LIMITS = require(script.Parent.GUILD_LIMITS)
const guild_snapshot_types = require(script.Parent.guild_snapshot_types)

const ASSET_PATTERN = "^rbxassetid://%d+$"

const function is_blank(text: string): boolean
	return string.match(text, "^%s*$") ~= nil
end

const function is_valid_asset(asset: string): boolean
	return asset == "" or string.match(asset, ASSET_PATTERN) ~= nil
end

-- returns a message for the player when something is wrong, nil when the info is fine
-- utf8.len is used so emoji and accents count as one character like the counters show
const function validate_guild_info(info: guild_snapshot_types.guild_info_input): string?
	const name_length = utf8.len(info.name)
	const description_length = utf8.len(info.description)
	if name_length == nil or description_length == nil then
		return "Text contains invalid characters."
	end
	if is_blank(info.name) then
		return "Your guild needs a name."
	end
	if name_length > GUILD_LIMITS.MAX_NAME_LENGTH then
		return `Guild names can be at most {GUILD_LIMITS.MAX_NAME_LENGTH} characters.`
	end
	if #info.tag < GUILD_LIMITS.MIN_TAG_LENGTH or #info.tag > GUILD_LIMITS.MAX_TAG_LENGTH then
		return `Guild tags must be {GUILD_LIMITS.MIN_TAG_LENGTH} to {GUILD_LIMITS.MAX_TAG_LENGTH} characters.`
	end
	if string.match(info.tag, GUILD_LIMITS.TAG_PATTERN) == nil then
		return "Guild tags can only contain letters and numbers."
	end
	if description_length > GUILD_LIMITS.MAX_DESCRIPTION_LENGTH then
		return `Guild descriptions can be at most {GUILD_LIMITS.MAX_DESCRIPTION_LENGTH} characters.`
	end
	if #info.discord_invite > GUILD_LIMITS.MAX_DISCORD_INVITE_LENGTH then
		return "That Discord invite is too long."
	end
	if not is_valid_asset(info.icon) or not is_valid_asset(info.banner) then
		return "Icons and banners must be image ids."
	end
	return nil
end

return validate_guild_info
