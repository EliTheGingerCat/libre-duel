export type click_type = "attack" | "use"

-- counted per button, because alternating between them (block hitting) isn't autoclicking even if the total is high
local cps_dictionary: { [click_type]: { [Player]: number } } = {
	attack = {},
	use = {},
}

return cps_dictionary
