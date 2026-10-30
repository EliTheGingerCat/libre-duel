const ReplicatedStorage = game:GetService("ReplicatedStorage")

const assert_cooldown_name = require(script.Parent.assert_cooldown_name)
const cooldowns = require(script.Parent.cooldowns)
const registry = require(ReplicatedStorage.shared.entity.registry)

local function remove_cooldown(entity: registry.entity, name: string): ()
	assert_cooldown_name(name)
	if cooldowns[entity] ~= nil then
		cooldowns[entity][name] = nil
	end
end

return remove_cooldown
