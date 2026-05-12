local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- ~ Todo: Which debug print to use?
local debug_print = print
local entity_mod = require(script.Parent.entity)
local replication = require(script.Parent.replication)

type entity = entity_mod.entity
local is_server = RunService:IsServer()
type replication_event = replication.replication_event

export type team = {
	cage: Model,
	id: number,
	goal: Part,
	members: {entity},
	name: string,
	points: number,
	spawn_part: Part,
	Roblox_team: Team,
}

local all_teams: {team} = {}
local class_id = 2
local class_placeholder: any
local properties = {"cage", "id", "goal", "name", "players", "points", "spawn_part", "Roblox_team"}

local team_id = 0

type property_name_map = {
	cage: number,
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
	goal: Part,
	members: {entity},
	name: string,
	points: number,
	spawn_part: Part,
	Roblox_team: Team,
}
-- Eli: Haha. Team Create.
local function team_create(options: creation_options): team
	team_id += 1
	
	local team: team = {
		cage = options.cage,
		id = team_id,
		goal = options.goal,
		members = options.members,
		name = options.name,
		points = options.points,
		spawn_part = options.spawn_part,
		Roblox_team = options.Roblox_team,
	}

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

		ReplicatedStorage.remotes.replication_special:FireAllClients({
			kind = "team_members_add",
			team_id = team.id,
			addees = addee_ids,
		})
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

		ReplicatedStorage.remotes.replication_special:FireAllClients({
			kind = "team_members_remove",
			team_id = team.id,
			addees = removee_ids,
		})
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
		team_add(event.object)
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
	elseif event.kind == "destroy" then
		local team = find_by_id(event.object_id)
		if team == nil then
			debug_print(`Error: No team was found with id {event.object_id}.`)
			return
		end

		team_destroy(team)
	else
		debug_print(`Unknown replication event kind "{event.kind}".`)
	end
end

local team_mod = {
	class_id = class_id,
	create = team_create,
	destroy = team_destroy,
	find_by_id = find_by_id,
	properties = properties,
	property_map = property_name_to_id,
	replication_receiver = receive_replication,

	members_add = members_add,
	members_remove = members_remove,
}
class_placeholder = team_mod

replication.register_class(team_mod)

return team_mod
