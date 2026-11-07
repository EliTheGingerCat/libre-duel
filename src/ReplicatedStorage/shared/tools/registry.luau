-- loads every tool in `definitions`, `inherits` copies the base tool then applies its own fields
const ReplicatedStorage = game:GetService("ReplicatedStorage")

const tool_types = require(ReplicatedStorage.shared.tools.tool_types)

-- TODO: replace with real icons
const PLACEHOLDER_IMAGE = "rbxasset://textures/ui/GuiImagePlaceholder.png"

const definitions = script.Parent.definitions

const tools: { [string]: tool_types.tool } = {}
const loading: { [string]: true } = {}
const overridden: { [tool_types.overrides]: tool_types.tool } = setmetatable({}, { __mode = "k" }) :: any

local function merge(base: { [any]: any }, overrides: { [any]: any }): { [any]: any }
	local merged = {}
	for key, value in base do
		merged[key] = value
	end
	for key, value in overrides do
		const base_value = merged[key]
		merged[key] = if type(value) == "table" and type(base_value) == "table" then merge(base_value, value) else value
	end
	return merged
end

local function deep_freeze<T>(value: T): T
	if type(value) == "table" and not table.isfrozen(value) then
		for _, child in value do
			deep_freeze(child)
		end
		table.freeze(value)
	end
	return value
end

local function load(id: string): tool_types.tool
	const existing = tools[id]
	if existing ~= nil then
		return existing
	end
	assert(loading[id] == nil, `Tool "{id}" inherits from itself.`)

	const module = definitions:FindFirstChild(id)
	assert(module ~= nil and module:IsA("ModuleScript"), `Tool "{id}" is not defined.`)
	loading[id] = true

	const definition: tool_types.definition = (require :: any)(module)
	const base: { [any]: any } = if definition.inherits ~= nil
		then load(definition.inherits)
		else { image = PLACEHOLDER_IMAGE, behaviours = {} }
	const merged = merge(base, {
		name = definition.name,
		image = definition.image,
		mesh = definition.mesh,
		behaviours = definition.behaviours,
	})
	merged.id = id
	assert(type(merged.name) == "string", `Tool "{id}" has no name.`)

	const tool: tool_types.tool = deep_freeze(merged) :: any
	tools[id] = tool
	loading[id] = nil
	return tool
end

for _, module in definitions:GetChildren() do
	load(module.Name)
end

local function get(id: string): tool_types.tool?
	return tools[id]
end

local function resolve(id: string, overrides: tool_types.overrides?): tool_types.tool?
	const tool = tools[id]
	if tool == nil or overrides == nil then
		return tool
	end
	local resolved = overridden[overrides]
	if resolved == nil then
		resolved = deep_freeze(merge(tool, overrides)) :: any
		overridden[overrides] = resolved
	end
	return resolved
end

local function has_behaviour(tool: tool_types.tool, behaviour: tool_types.behaviour): boolean
	return (tool.behaviours :: any)[behaviour] ~= nil
end

return {
	get = get,
	resolve = resolve,
	has_behaviour = has_behaviour,
}
