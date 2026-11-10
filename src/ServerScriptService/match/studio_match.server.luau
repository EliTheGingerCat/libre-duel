const ReplicatedStorage = game:GetService("ReplicatedStorage")
const RunService = game:GetService("RunService")

const get_mode_definition = require(ReplicatedStorage.shared.modes.get_mode_definition)
const match = require(script.Parent.match)
const MODE_DEFINITIONS = require(ReplicatedStorage.shared.modes.MODE_DEFINITIONS)
const registry = require(ReplicatedStorage.shared.entity.registry)
const start_match = require(script.Parent.start_match)

-- Studio cannot be teleported into a queued match, so it starts one with whoever is around.
if not RunService:IsStudio() then
	return
end

const STUDIO_MODE: MODE_DEFINITIONS.mode_id = "bridge_solo"
const START_DELAY = 5

local current: match.match? = nil
local start_thread: thread? = nil

local function start(): ()
	start_thread = nil
	const entities = registry.get_all()
	if current ~= nil or #entities == 0 then
		return
	end

	const definition = get_mode_definition(STUDIO_MODE)
	const teams: { { registry.entity } } = {}
	for index = 1, definition.teams do
		teams[index] = {}
	end
	for index, entity in entities do
		table.insert(teams[(index - 1) % definition.teams + 1], entity)
	end

	const new_match = start_match(definition, teams)
	local function on_stop(): ()
		if current == new_match then
			current = nil
		end
	end
	current = new_match
	match.on_stop(new_match, on_stop)
end

local function schedule_start(): ()
	if current == nil and start_thread == nil and #registry.get_all() > 0 then
		start_thread = task.delay(START_DELAY, start)
	end
end

local function on_entity_added(entity: registry.entity): ()
	if current then
		match.add_entity(current, entity)
	else
		schedule_start()
	end
end

registry.added:Connect(on_entity_added)
registry.removed:Connect(schedule_start)
schedule_start()
