export type cube_params = {
	colour: Color3?,
	material: Enum.Material?,
	shape: Enum.PartType?,
}
export type sword_params = {
	damage: number?,
}
export type no_params = {}

export type behaviours = {
	sword: sword_params?,
	cube: cube_params?,
	dissolver: no_params?,
	bow: no_params?,
	cake: no_params?,
	mode_selector: no_params?,
}
export type behaviour = "sword" | "cube" | "dissolver" | "bow" | "cake" | "mode_selector"

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
	behaviours: behaviours?,
}

export type tool = {
	id: string,
	name: string,
	image: string,
	behaviours: behaviours,
}

return {}
