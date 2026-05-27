local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- ~ Todo: Which debug print to use?
local debug_print = print
local entity_mod = require(script.Parent.entity)
local replication = require(script.Parent.replication)
local signal = require(ReplicatedStorage.Packages.signal)

type entity = entity_mod.entity
local is_server = RunService:IsServer()
type replication_event = replication.replication_event

export type team = {
	cage: Model,
	colour: Color3,
	id: number,
	goal: Part,
	goal_listener: RBXScriptConnection,
	members: {entity},
	name: string,
	points: number,
	spawn_part: Part,
	Roblox_team: Team,
}

local all_teams: {team} = {}
local class_id = 2
local class_placeholder: any
local on_any_team_changed = signal.new()
local properties = {"cage", "colour", "id", "goal", "name", "players", "points", "spawn_part", "Roblox_team"}

local team_id = 0

type property_name_map = {
	cage: number,
	colour: Color3,
	id: number,
	goal: number,
	members: number,
	name: number,
	points: number,
	spawn_part: number,
	Roblox_team: number,
}
local property_name_to_id: property_name_map = {} :: any
for id, name in properties do
	property_name_to_id[name] = id
end

local function team_add(team: team): ()
	table.insert(all_teams, team)
end

type creation_options = {
	cage: Model,
	colour: Color3,
	goal: Part,
	name: string,
	points: number,
	Roblox_team: Team,
	spawn_part: Part,
}
-- Eli: Haha. Team Create.
local function team_create(options: creation_options): team
	team_id += 1
	
	local team: team = {
		cage = options.cage,
		colour = options.colour,
		id = team_id,
		goal = options.goal,
		goal_listener = nil :: any,
		members = {},
		name = options.name,
		points = options.points,
		Roblox_team = options.Roblox_team,
		spawn_part = options.spawn_part,
	}

	-- Eli: `members` is not an option since the initial `members` are cleared in `receive_replication`.

	-- Eli: `goal_listener` is added later, so it is not sent to the clients, though I think signal connections can not be sent over the network anyway. Regardless,
	-- `goal_listener = nil :: any` is bad practice.

	team_add(team)

	if is_server == true then
		replication.replicate_create(class_placeholder, team)
	end

	return team
end

local function find_by_id(id: number): team?
	for _, team in all_teams do
		if team.id == id then
			return team
		end
	end

	return nil
end

local function table_union_mutating<V>(into: {V}, from: {V}): ()
	table.move(from, 1, #from, #into + 1, into)
end

local function get_entity_ids(entities: {entity}): {number}
	local ids: {number} = {}
	for index, entity in entities do
		ids[index] = entity.id
	end
	return ids
end

local function members_add(team: team, addees: {entity}): ()
	table_union_mutating(team.members, addees)
	
	if is_server == true then
		local addee_ids = get_entity_ids(addees)

		local event: replication.team_members_add = {
			kind = "special",
			kind_2 = "team_members_add",
			team_id = team.id,
			addees = addee_ids,
		}
		table.insert(replication.all_replication_events, event)
	end
end

local function members_remove(team: team, removees: {entity}): ()
	for _, entity in removees do
		local index = table.find(team.members, entity)
		if index == nil then
			local reference = entity_mod.get_textual_reference(entity)
			debug_print(`Entity {reference} was not found in team.`)
			continue
		end

		table.remove(team.members, index)
	end

	if is_server == true then
		local removee_ids = get_entity_ids(removees)

		local event: replication.team_members_remove = {
			kind = "special",
			kind_2 = "team_members_remove",
			team_id = team.id,
			removees = removee_ids,
		}
		table.insert(replication.all_replication_events, event)
	end
end

local function team_destroy(team: team): ()
	local index = table.find(all_teams, team)
	table.remove(all_teams, index)

	if is_server then
		replication.replicate_destroy(class_placeholder, team.id)
	end

	table.clear(team)
	local husk: {[any]: any} = team
	husk["Huh?"] = "Was formerly a team."
end

--- @client
local function receive_replication(event: replication_event): ()
	if event.kind == "create" then
		local team: team = event.object
		-- If this is not cleared, duplication will occur if members are added to a team in the same frame as when the team was created.
		table.clear(team.members)
		team_add(event.object)
		on_any_team_changed:Fire()
	elseif event.kind == "update" then
		local object_id = event.object_id
		local property_id = event.property_id
		local property_value = event.property_value

		local team = find_by_id(object_id)
		if team == nil then
			debug_print(`Error: No team was found with id {object_id}.`)
			return
		end

		local property_index = properties[property_id]
		if property_index == nil then
			debug_print(`Error: No property was found with id {property_id}.`)
			return
		end

		team[property_index] = property_value
		on_any_team_changed:Fire()
	elseif event.kind == "destroy" then
		local team = find_by_id(event.object_id)
		if team == nil then
			debug_print(`Error: No team was found with id {event.object_id}.`)
			return
		end

		team_destroy(team)
		on_any_team_changed:Fire()
	else
		debug_print(`Unknown replication event kind "{event.kind}".`)
	end
end

local team_mod = {
	all_teams = all_teams,
	class_id = class_id,
	create = team_create,
	destroy = team_destroy,
	find_by_id = find_by_id,
	on_any_team_changed = on_any_team_changed,
	properties = properties,
	property_map = property_name_to_id,
	replication_receiver = receive_replication,

	members_add = members_add,
	members_remove = members_remove,
}
class_placeholder = team_mod

replication.register_class(team_mod)

return team_mod
