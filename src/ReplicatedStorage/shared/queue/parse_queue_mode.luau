const ReplicatedStorage = game:GetService("ReplicatedStorage")

const MODE_DEFINITIONS = require(ReplicatedStorage.shared.modes.MODE_DEFINITIONS)

local function parse_queue_mode(value: unknown): MODE_DEFINITIONS.mode_id?
	for _, definition in MODE_DEFINITIONS do
		if value == definition.id then
			return definition.id
		end
	end
	return nil
end

return parse_queue_mode
