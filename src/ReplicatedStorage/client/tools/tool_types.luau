export type id = "sword" | "cube" | "dissolver" | "bow" | "cake"

-- Hooks run without yielding so switching can always cancel the outgoing tool.
export type tool = {
	begin_use: () -> (),
	cancel_use: (() -> ())?,
	end_use: (() -> ())?,
	equip: (() -> ())?,
	unequip: (() -> ())?,
	buffer_click: boolean?,
}

export type factory = () -> tool

return {}
