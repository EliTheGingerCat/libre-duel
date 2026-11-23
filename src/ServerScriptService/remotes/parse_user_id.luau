-- negative ids are allowed since studio test players have them
const function parse_user_id(value: unknown): number?
	if typeof(value) ~= "number" or value ~= value or value == 0 or value % 1 ~= 0 then
		return nil
	end
	return value
end

return parse_user_id
