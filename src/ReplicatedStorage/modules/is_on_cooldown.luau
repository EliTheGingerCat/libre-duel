local cooldowns = require(script.Parent.cooldowns)
local remove_cooldown = require(script.Parent.remove_cooldown)

type player_cooldown = cooldowns.player_cooldowns

local function is_on_cooldown(player: Player, name: string): boolean
	local player_cooldowns: player_cooldown? = cooldowns[player]
	if player_cooldowns == nil then
		return false
	end

	local end_time: number? = player_cooldowns[name]
	if end_time == nil then
		return false
	end

	local is_cool = end_time > os.clock()

	if is_cool then
		remove_cooldown(player, name)
	end

	return is_cool
end

return is_on_cooldown
