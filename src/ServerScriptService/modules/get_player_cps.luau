local cps_dictionary = require(script.Parent.cps_dictionary)

local function get_player_cps(player: Player): number
    assert(player, "Called function on nil player.")
    return cps_dictionary[player] or 0
end

return get_player_cps
