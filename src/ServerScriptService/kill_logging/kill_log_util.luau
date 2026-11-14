const ReplicatedStorage = game:GetService("ReplicatedStorage")
const registry = require(ReplicatedStorage.shared.entity.registry)

const MARKING_DURATION = require(script.Parent.MARKING_DURATION)
const marked_entities = require(script.Parent.marked_entities)

local kill_log_util = {}

function kill_log_util.mark_entity(attacker: registry.entity, target: registry.entity): ()
	marked_entities[target] = {
		marked_by = attacker,
		last_marked = os.clock(),
	}
end

function kill_log_util.unmark_entity(entity: registry.entity): ()
	marked_entities[entity] = nil
end

function kill_log_util.unmark_every_entity(): ()
	for _, entity in ipairs(registry.get_all()) do
		kill_log_util.unmark_entity(entity)
	end
end

function kill_log_util.get_entity_who_marked(entity: registry.entity): registry.entity | nil
	if not marked_entities[entity] then
		return
	end
	if os.clock() - marked_entities[entity].last_marked > MARKING_DURATION then
		kill_log_util.unmark_entity(entity)
		return
	end
	return marked_entities[entity].marked_by
end

return kill_log_util
