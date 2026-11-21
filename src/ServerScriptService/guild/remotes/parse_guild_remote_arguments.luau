const ReplicatedStorage = game:GetService("ReplicatedStorage")

const guild_snapshot_types = require(ReplicatedStorage.shared.guild.guild_snapshot_types)

-- HttpService:GenerateGUID(false), 36 characters of hex and dashes
const GUILD_ID_PATTERN = "^%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x$"
const MAX_INPUT_LENGTH = 40000

-- negative ids are allowed since studio test players have them
const function parse_user_id(value: unknown): number?
	if typeof(value) ~= "number" or value ~= value or value == 0 or value % 1 ~= 0 then
		return nil
	end
	return value
end

const function parse_guild_id(value: unknown): string?
	if typeof(value) ~= "string" or string.match(value, GUILD_ID_PATTERN) == nil then
		return nil
	end
	return value
end

const function parse_short_string(value: unknown): string?
	if typeof(value) ~= "string" or #value > MAX_INPUT_LENGTH then
		return nil
	end
	return value
end

const function parse_guild_info_input(value: unknown): guild_snapshot_types.guild_info_input?
	if typeof(value) ~= "table" then
		return nil
	end
	const raw = value :: { [unknown]: unknown }
	const name = parse_short_string(raw.name)
	const tag = parse_short_string(raw.tag)
	const description = parse_short_string(raw.description)
	const icon = parse_short_string(raw.icon)
	const banner = parse_short_string(raw.banner)
	const discord_invite = parse_short_string(raw.discord_invite)
	if name == nil or tag == nil or description == nil or icon == nil or banner == nil or discord_invite == nil then
		return nil
	end
	return {
		name = name,
		tag = tag,
		description = description,
		icon = icon,
		banner = banner,
		discord_invite = discord_invite,
	}
end

return {
	parse_user_id = parse_user_id,
	parse_guild_id = parse_guild_id,
	parse_short_string = parse_short_string,
	parse_guild_info_input = parse_guild_info_input,
}
