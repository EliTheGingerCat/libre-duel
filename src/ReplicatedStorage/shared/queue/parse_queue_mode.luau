const QUEUE_MODES = require(script.Parent.QUEUE_MODES)

local function parse_queue_mode(value: unknown): QUEUE_MODES.mode?
	for _, mode in QUEUE_MODES do
		if value == mode then
			return mode
		end
	end
	return nil
end

return parse_queue_mode
