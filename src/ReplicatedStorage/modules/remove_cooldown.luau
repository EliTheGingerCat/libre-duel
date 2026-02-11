local assert_cooldown_name = require(script.Parent.assert_cooldown_name)
local cooldowns = require(script.Parent.cooldowns)

local function remove_cooldown(player: Player, name: string): ()
	assert_cooldown_name(name)
	if cooldowns[player] ~= nil then
		cooldowns[player][name] = nil
	end
end

return remove_cooldown
