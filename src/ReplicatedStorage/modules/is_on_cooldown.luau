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

	if end_time > os.clock() then
		return true
	end

	remove_cooldown(player, name)
	return false
end

return is_on_cooldown
