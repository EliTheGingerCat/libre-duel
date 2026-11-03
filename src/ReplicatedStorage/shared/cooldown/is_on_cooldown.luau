const ReplicatedStorage = game:GetService("ReplicatedStorage")

const cooldowns = require(script.Parent.cooldowns)
const registry = require(ReplicatedStorage.shared.entity.registry)
const remove_cooldown = require(script.Parent.remove_cooldown)

type entity_cooldown = cooldowns.entity_cooldowns

local function is_on_cooldown(entity: registry.entity, name: string): boolean
	const entity_cooldowns: entity_cooldown? = cooldowns[entity]
	if entity_cooldowns == nil then
		return false
	end

	const end_time: number? = entity_cooldowns[name]
	if end_time == nil then
		return false
	end

	if end_time > os.clock() then
		return true
	end

	remove_cooldown(entity, name)
	return false
end

return is_on_cooldown
