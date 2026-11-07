local cps_dictionary = require(script.Parent.cps_dictionary)

local function get_player_cps(player: Player, click_type: cps_dictionary.click_type): number
	assert(player, "Called function on nil player.")
	return cps_dictionary[click_type][player] or 0
end

return get_player_cps
