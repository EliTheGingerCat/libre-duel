const ReplicatedStorage = game:GetService("ReplicatedStorage")
const ServerScriptService = game:GetService("ServerScriptService")

const match = require(script.Parent.match)
const MODE_DEFINITIONS = require(ReplicatedStorage.shared.modes.MODE_DEFINITIONS)
const registry = require(ReplicatedStorage.shared.entity.registry)

const load_mode: (ModuleScript) -> match.mode = require

-- The mode is the module in `modes` named after the definition's `game`.
const function start_match(definition: MODE_DEFINITIONS.definition, teams: { { registry.entity } }): match.match
	const module = ServerScriptService.modes:FindFirstChild(definition.game)
	assert(module and module:IsA("ModuleScript"), `No mode module for "{definition.game}"`)
	const mode = load_mode(module)
	const new_match = match.create(definition)
	match.start(new_match, mode.new(new_match), teams)
	return new_match
end

return start_match
