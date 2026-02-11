local assert_cooldown_name = require(script.Parent.assert_cooldown_name)
local cooldowns = require(script.Parent.cooldowns)

local function add_cooldown(player: Player, name: string, duration: number): ()
	assert_cooldown_name(name)
	cooldowns[player] = cooldowns[player] or {}
	cooldowns[player][name] = os.clock() + duration
end

return add_cooldown
