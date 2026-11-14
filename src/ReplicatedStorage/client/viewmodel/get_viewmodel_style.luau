const ReplicatedStorage = game:GetService("ReplicatedStorage")

const block_animation = require(script.Parent.block_animation)
const bow_display = require(script.Parent.bow_display)
const cube_display = require(script.Parent.cube_display)
const eat_animation = require(script.Parent.eat_animation)
const mesh_display = require(script.Parent.mesh_display)
const tool_registry = require(ReplicatedStorage.shared.tools.registry)
const tool_types = require(ReplicatedStorage.shared.tools.tool_types)
const viewmodel_types = require(script.Parent.viewmodel_types)

-- the display modules carry extra functions of their own, so they are narrowed to what a style needs
-- the mesh one can't be cast, and every mesh style has to share this table since displays are compared by identity
const MESH_DISPLAY: viewmodel_types.display = {
	show = mesh_display.show,
	hide = mesh_display.hide,
	get_part = mesh_display.get_part,
	set_transparency = mesh_display.set_transparency,
}
const CUBE_DISPLAY = cube_display :: viewmodel_types.display
const BOW_DISPLAY = bow_display :: viewmodel_types.display

const DEFAULT_STYLE: viewmodel_types.style = { display = MESH_DISPLAY, swings_on_use = true }

-- a list so that a tool with several behaviours always gets the same style
const STYLES: { { behaviour: tool_types.behaviour, style: viewmodel_types.style } } = {
	{ behaviour = "cube", style = { display = CUBE_DISPLAY, swings_on_use = true } },
	{ behaviour = "bow", style = { display = BOW_DISPLAY } },
	{ behaviour = "cake", style = { display = MESH_DISPLAY, use_animation = eat_animation } },
	{ behaviour = "sword", style = { display = MESH_DISPLAY, use_animation = block_animation } },
	{ behaviour = "pickaxe", style = { display = MESH_DISPLAY } },
}

const function get_viewmodel_style(tool: tool_types.tool): viewmodel_types.style
	for _, entry in STYLES do
		if tool_registry.has_behaviour(tool, entry.behaviour) then
			return entry.style
		end
	end
	return DEFAULT_STYLE
end

return get_viewmodel_style
