export type cube_params = {
	colour: Color3?,
	material: Enum.Material?,
	shape: Enum.PartType?,
	texture_id: string?,
}
export type sword_params = {
	damage: number?,
}
export type bow_draw_frame = {
	mesh: string,
	texture: string,
}
-- shown in order while drawing, from the start of the draw to full power
export type bow_params = {
	draw_frames: { bow_draw_frame }?,
}
export type no_params = {}

export type behaviours = {
	sword: sword_params?,
	cube: cube_params?,
	pickaxe: no_params?,
	bow: bow_params?,
	cake: no_params?,
	mode_selector: no_params?,
}
export type behaviour = "sword" | "cube" | "pickaxe" | "bow" | "cake" | "mode_selector"

export type overrides = {
	name: string?,
	image: string?,
	behaviours: behaviours?,
}

-- the module's name is the tool id (・ω・)
export type definition = {
	inherits: string?,
	name: string?,
	image: string?,
	mesh: string?,
	behaviours: behaviours?,
}

export type tool = {
	id: string,
	name: string,
	image: string,
	mesh: string?,
	behaviours: behaviours,
}

return {}
