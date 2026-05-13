local ReplicatedStorage = game:GetService("ReplicatedStorage")

local debug_print = require(ReplicatedStorage.client.util.debug_print)
local entity_mod = require(ReplicatedStorage.shared.entity)
local replication = require(ReplicatedStorage.shared.replication)
local team_mod = require(ReplicatedStorage.shared.team)

type replication_event = replication.replication_event
type replication_event_special = replication.replication_event_special
type team = team_mod.team

local function find_entity_id_in_team(team: team, entity_id: number): number?
	for index, entity in team.members do
		if entity.id == entity_id then
			return index
		end
	end

	return nil
end

local function on_event_special(event: replication_event_special): ()
	if event.kind_2 == "team_members_add" then
		local team = team_mod.find_by_id(event.team_id)
		if team == nil then
			debug_print(`Error: Team of id {event.team_id} was not found.`)
			return
		end

		for _, entity_id in event.addees do
			local entity = entity_mod.find_by_id(entity_id)
			if entity == nil then
				debug_print(`Error: Entity of id {entity_id} was not found.`)
				continue
			end

			table.insert(team.members, entity)
		end
	elseif event.kind_2 == "team_members_remove" then
		local team = team_mod.find_by_id(event.team_id)
		if team == nil then
			debug_print(`Error: Team of id {event.team_id} was not found.`)
			return
		end

		for _, entity_id in event.removees do
			local index = find_entity_id_in_team(team, entity_id)
			if index == nil then
				debug_print(`Error: Entity of id {entity_id} was not found in team of id {team.id}.`)
				return
			end

			table.remove(team.members, index)
		end
	end
end

local function on_event(events: {replication_event}): ()
	for _, event in events do
		if event.kind == "special" then
			on_event_special(event)
		else
			replication.all_classes[event.class_id].replication_receiver(event)
		end
	end
end
ReplicatedStorage.remotes.replication.OnClientEvent:Connect(on_event)
