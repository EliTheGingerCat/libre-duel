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
	-- icon shown in the hotbar and inventory
	image: string,
	appearance: appearance,
}

-- TODO: replace with real icons
const PLACEHOLDER_IMAGE = "rbxasset://textures/ui/GuiImagePlaceholder.png"

const tools: { [string]: tool } = {}

local function add(item: tool): ()
	assert(tools[item.id] == nil, `Tool "{item.id}" is already registered.`)
	tools[item.id] = table.freeze(item)
end

local function define(id: string, name: string, behaviour: behaviour, image: string, appearance: appearance?): ()
	add({
		id = id,
		name = name,
		behaviour = behaviour,
		image = image,
		appearance = table.freeze(appearance or {}),
	})
end

-- `image` defaults to the base tool's image
local function define_variant(id: string, base_id: string, name: string, overrides: appearance, image: string?): ()
	const base = tools[base_id]
	assert(base ~= nil, `Base tool "{base_id}" of variant "{id}" is not registered.`)

	add({
		id = id,
		name = name,
		behaviour = base.behaviour,
		image = image or base.image,
		appearance = table.freeze({
			colour = overrides.colour or base.appearance.colour,
			material = overrides.material or base.appearance.material,
			shape = overrides.shape or base.appearance.shape,
		}),
	})
end

define("sword", "Sword", "sword", PLACEHOLDER_IMAGE)
define("cube", "Cube", "cube", PLACEHOLDER_IMAGE, {
	material = Enum.Material.Brick,
})
define("dissolver", "Dissolver", "dissolver", PLACEHOLDER_IMAGE)
define("bow", "Bow", "bow", PLACEHOLDER_IMAGE)
define("cake", "Cake", "cake", PLACEHOLDER_IMAGE)
define("mode_selector", "Modes", "mode_selector", PLACEHOLDER_IMAGE)

local function get(id: string): tool?
	return tools[id]
end

return {
	get = get,
}
