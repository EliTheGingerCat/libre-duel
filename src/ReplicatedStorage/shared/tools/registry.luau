-- Every tool is registered here. A variant shares its base tool's behaviour and overrides its appearance.

export type behaviour = "sword" | "cube" | "dissolver" | "bow" | "cake" | "mode_selector"

-- Properties applied to whatever the tool produces, such as a placed cube. Unset fields keep the default.
export type appearance = {
	colour: Color3?,
	material: Enum.Material?,
	shape: Enum.PartType?,
}

export type tool = {
	id: string,
	name: string,
	behaviour: behaviour,
	appearance: appearance,
}

const tools: { [string]: tool } = {}

local function add(item: tool): ()
	assert(tools[item.id] == nil, `Tool "{item.id}" is already registered.`)
	tools[item.id] = table.freeze(item)
end

local function define(id: string, name: string, behaviour: behaviour, appearance: appearance?): ()
	add({
		id = id,
		name = name,
		behaviour = behaviour,
		appearance = table.freeze(appearance or {}),
	})
end

local function define_variant(id: string, base_id: string, name: string, overrides: appearance): ()
	const base = tools[base_id]
	assert(base ~= nil, `Base tool "{base_id}" of variant "{id}" is not registered.`)

	add({
		id = id,
		name = name,
		behaviour = base.behaviour,
		appearance = table.freeze({
			colour = overrides.colour or base.appearance.colour,
			material = overrides.material or base.appearance.material,
			shape = overrides.shape or base.appearance.shape,
		}),
	})
end

define("sword", "Sword", "sword")
define("cube", "Cube", "cube", {
	material = Enum.Material.Brick,
})
define("dissolver", "Dissolver", "dissolver")
define("bow", "Bow", "bow")
define("cake", "Cake", "cake")
define("mode_selector", "Modes", "mode_selector")

local function get(id: string): tool?
	return tools[id]
end

return {
	get = get,
}
