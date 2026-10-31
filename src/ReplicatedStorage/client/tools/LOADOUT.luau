const tool_types = require(script.Parent.tool_types)

const LOADOUT: { [number]: tool_types.id } = {
	[1] = "sword",
	[2] = "cube",
	[3] = "dissolver",
	[4] = "bow",
	[5] = "cake",
}

return LOADOUT
