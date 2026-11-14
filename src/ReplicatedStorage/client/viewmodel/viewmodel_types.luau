const ReplicatedStorage = game:GetService("ReplicatedStorage")

const tool_types = require(ReplicatedStorage.shared.tools.tool_types)

-- how an item appears in the viewmodel
export type display = {
	show: (tool: tool_types.tool) -> (),
	hide: () -> (),
	get_part: () -> BasePart?,
	set_transparency: (transparency: number) -> (),
	update: ((tool: tool_types.tool) -> ())?,
}

-- how an item is posed while it is being used
export type use_animation = {
	get_offset: (delta_time: number) -> CFrame,
}

export type style = {
	display: display,
	swings_on_use: boolean?,
	use_animation: use_animation?,
}

return {}
