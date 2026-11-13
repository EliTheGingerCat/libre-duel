const MODE_DEFINITIONS = require(script.Parent.MODE_DEFINITIONS)

const definitions_by_id: { [string]: MODE_DEFINITIONS.definition } = {}
for _, definition in MODE_DEFINITIONS do
	definitions_by_id[definition.id] = definition
end

const function get_mode_definition(id: MODE_DEFINITIONS.mode_id): MODE_DEFINITIONS.definition
	return definitions_by_id[id]
end

return get_mode_definition
