local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local generate_random_username = require(ReplicatedStorage.shared.util.generate_random_username)
local table_util = require(ReplicatedStorage.Packages["table-util"])

local join_queue = ReplicatedStorage.remotes.join_queue

local leave_queue = ReplicatedStorage.remotes.leave_queue

type entity = Player | string
type mode = "solo" | "duo"
type team = string
type guid = string

type queue_type = {
	teams: number,
	ept: number, -- ept: entities per team
}

type queue_types = {
	[mode]: queue_type,
}

local queue_types: queue_types = {
	solo = {
		teams = 2,
		ept = 1,
	},
	duo = {
		teams = 2,
		ept = 2,
	},
}

type open_queue = {
	guid: guid,
	mode: mode,
	teams: { [team]: { entity } },
}

type open_queues = {
	[guid]: open_queue,
}

local open_queues: open_queues = {}

type queueing_entities = { [entity]: {
	queue: guid,
	team: team,
} }

local queueing_entities: queueing_entities = {}

type error = "entity_already_queued" | "entity_already_not_queued"

type success = true

local function get_open_queue(mode: mode): open_queue
	for i, v in open_queues do
		if open_queues[i]["mode"] == mode then
			return open_queues[i]
		end
	end

	local guid: guid = HttpService:GenerateGUID()
	const teams: { [team]: { entity } } = {}
	for team_index = 1, queue_types[mode].teams do
		teams[`team{team_index}`] = {}
	end

	open_queues[guid] = {
		guid = guid,
		mode = mode,
		teams = teams,
	}
	return open_queues[guid]
end

local function get_smaller_team(queue: open_queue): team
	local smaller_team: team? = nil
	local smaller_size = math.huge
	for team_name, team_entities in queue.teams do
		const size = #team_entities
		if size < smaller_size then
			smaller_team = team_name
			smaller_size = size
		end
	end
	assert(smaller_team)
	return smaller_team
end

local function get_entity_queue(entity: entity): open_queue?
	local v = queueing_entities[entity]
	if not v then
		return nil
	else
		return open_queues[v.queue]
	end
end

-- true: the queue is full!
local function is_queue_full(guid: guid): boolean
	local target = open_queues[guid]
	local entity_count = 0
	for _, team_entities in target.teams do
		entity_count += #team_entities
	end
	return entity_count >= queue_types[target.mode].teams * queue_types[target.mode].ept
end

local function remove_entity_from_queue(entity: entity): ()
	local entity_queue = queueing_entities[entity]

	if not entity_queue then
		return
	end

	local queue = open_queues[entity_queue.queue]
	if not queue then
		return
	end

	const team_entities = queue.teams[entity_queue.team]

	local index = table.find(team_entities, entity)
	if index then
		table.remove(team_entities, index)
	end

	queueing_entities[entity] = nil
end

local function on_queue_filled(guid: guid): ()
	table.freeze(open_queues[guid])
	local t = table_util.Copy(open_queues[guid], true)
	open_queues[guid] = nil

	for team_name, team_entities in t.teams do
		for _, entity in team_entities do
			print(`Teleporting {entity} to the game as {team_name}`)
			remove_entity_from_queue(entity)
		end
	end
end

local function enter_entity_into_queue(entity: entity, guid: guid, lazy: boolean): error | success
	if get_entity_queue(entity) and lazy then
		return "entity_already_queued"
	end
	if get_entity_queue(entity) and not lazy then
		remove_entity_from_queue(entity)
	end
	local queue = open_queues[guid]
	const selected_team = get_smaller_team(queue)
	queueing_entities[entity] = {
		queue = queue.guid,
		team = selected_team,
	}
	table.insert(queue.teams[selected_team], entity)

	if is_queue_full(guid) then
		on_queue_filled(guid)
	end
	return true
end

for i = 1, 4 do
	local rand = generate_random_username()
	enter_entity_into_queue(rand, get_open_queue("duo").guid, false)
	print(`added {rand} into the queue`)
end

print(open_queues)

Players.PlayerRemoving:Connect(function(player)
	remove_entity_from_queue(player)
end)

join_queue.OnServerInvoke = function(entity)
	enter_entity_into_queue(entity, get_open_queue("solo").guid, false)
	print(get_entity_queue(entity))
end

leave_queue.OnServerInvoke = function(entity)
	remove_entity_from_queue(entity)
	print(get_entity_queue(entity))
	print(open_queues)
end
