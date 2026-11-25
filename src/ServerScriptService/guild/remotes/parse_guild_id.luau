-- HttpService:GenerateGUID(false), 36 characters of hex and dashes
const GUILD_ID_PATTERN = "^%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x$"

-- zap only checks the length, so the format still has to be checked
const function parse_guild_id(value: string): string?
	if string.match(value, GUILD_ID_PATTERN) == nil then
		return nil
	end
	return value
end

return parse_guild_id
