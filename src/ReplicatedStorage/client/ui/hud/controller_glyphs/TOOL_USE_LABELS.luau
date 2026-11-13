const ReplicatedStorage = game:GetService("ReplicatedStorage")

const tool_types = require(ReplicatedStorage.shared.tools.tool_types)

-- checked in order, the first behaviour the held tool has names its use glyph
const TOOL_USE_LABELS: { { behaviour: tool_types.behaviour, label: string } } = {
	{ behaviour = "bow", label = "Shoot" },
	{ behaviour = "cake", label = "Eat" },
	{ behaviour = "cube", label = "Place" },
	{ behaviour = "mode_selector", label = "Choose mode" },
	{ behaviour = "sword", label = "Block" },
}

return table.freeze(TOOL_USE_LABELS)
