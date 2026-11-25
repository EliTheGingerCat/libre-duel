const ReplicatedStorage = game:GetService("ReplicatedStorage")

const gl_transform = require(script.Parent.first_person.gl_transform)
const tool_types = require(ReplicatedStorage.shared.tools.tool_types)

-- how an item appears in the viewmodel
export type display = {
	show: (tool: tool_types.tool) -> (),
	hide: () -> (),
	set_transparency: (transparency: number) -> (),
	-- cframe is the centre of the item model, studs_per_unit is how big one gl unit of the model is
	set_pose: (cframe: CFrame, studs_per_unit: number) -> (),
	update: ((tool: tool_types.tool) -> ())?,
}

-- how an item is posed while it is being used, split around transformFirstPersonItem like the source
export type use_animation = {
	is_using: () -> boolean,
	apply_before_hold: ((transform: gl_transform.gl_transform) -> ())?,
	apply_after_hold: ((transform: gl_transform.gl_transform) -> ())?,
}

export type style = {
	display: display,
	is_block_model: boolean?,
	swings_on_use: boolean?,
	use_animation: use_animation?,
}

return {}
