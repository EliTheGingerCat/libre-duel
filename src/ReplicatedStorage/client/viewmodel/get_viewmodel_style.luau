const ReplicatedStorage = game:GetService("ReplicatedStorage")

const block_animation = require(script.Parent.block_animation)
const bow_display = require(script.Parent.bow_display)
const cube_display = require(script.Parent.cube_display)
const eat_animation = require(script.Parent.eat_animation)
const mesh_display = require(script.Parent.mesh_display)
const tool_registry = require(ReplicatedStorage.shared.tools.registry)
const tool_types = require(ReplicatedStorage.shared.tools.tool_types)
const viewmodel_types = require(script.Parent.viewmodel_types)

const DEFAULT_STYLE: viewmodel_types.style = { display = mesh_display, swings_on_use = true }

-- a list so that a tool with several behaviours always gets the same style
const STYLES: { { behaviour: tool_types.behaviour, style: viewmodel_types.style } } = {
    { behaviour = "cube", style = { display = cube_display, swings_on_use = true } },
    { behaviour = "bow", style = { display = bow_display } },
    { behaviour = "cake", style = { display = mesh_display, use_animation = eat_animation } },
    { behaviour = "sword", style = { display = mesh_display, use_animation = block_animation } },
    { behaviour = "pickaxe", style = { display = mesh_display } },
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
