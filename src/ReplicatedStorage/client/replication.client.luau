local ReplicatedStorage = game:GetService("ReplicatedStorage")

local debug_print = require(ReplicatedStorage.client.util.debug_print)
local entity_mod = require(ReplicatedStorage.shared.entity)
local replication = require(ReplicatedStorage.shared.replication)
local team_mod = require(ReplicatedStorage.shared.team)

type replication_event = replication.replication_event

local function on_event_regular(events: {replication_event}): ()
	for _, event in events do
		replication.all_classes[event.class_id].replication_receiver(event)
	end
end
ReplicatedStorage.remotes.replication.OnClientEvent:Connect(on_event_regular)

type special_event = {
	kind: "team_members_add",
	team_id: number,
	addees: {number},
}

local function on_event_special(event: special_event): ()
	if event.kind == "team_members_add" then
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
	end
end

ReplicatedStorage.remotes.replication_special.OnClientEvent:Connect(on_event_special)
