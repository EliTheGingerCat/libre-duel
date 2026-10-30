const ReplicatedStorage = game:GetService("ReplicatedStorage")

const assert_cooldown_name = require(script.Parent.assert_cooldown_name)
const cooldowns = require(script.Parent.cooldowns)
const registry = require(ReplicatedStorage.shared.entity.registry)

local function add_cooldown(entity: registry.entity, name: string, duration: number): ()
	assert_cooldown_name(name)
	cooldowns[entity] = cooldowns[entity] or {}
	cooldowns[entity][name] = os.clock() + duration
end

return add_cooldown
