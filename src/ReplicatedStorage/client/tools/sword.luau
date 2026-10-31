const attack_melee = require(script.Parent.Parent.combat.attack_melee)
const tool_types = require(script.Parent.tool_types)

local function create(): tool_types.tool
	return {
		begin_use = attack_melee,
	}
end

return create
