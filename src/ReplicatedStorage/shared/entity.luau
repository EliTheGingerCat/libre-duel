local RunService = game:GetService("RunService")

local debug_print = print
local replication = require(script.Parent.replication)

local is_server = RunService:IsServer() == true
type replication_event = replication.replication_event

export type entity = {
	character: Model?,
	id: number,
	is_bot: boolean,
	name: string?,
	player: Player?,
	team_id: number?,
}

local all_entities: {entity} = {}
local class_id = 1
local class_placeholder: any
local properties = {"character", "id", "player", "team"}

local entity_id = 0

type property_name_map = {
	character: number,
	id: number,
	is_bot: number,
	name: number,
	player: number,
	team: number,
}
local property_name_to_id: property_name_map = {} :: any
for id, name in properties do
	property_name_to_id[name] = id
end

local function entity_add(entity: entity): ()
	table.insert(all_entities, entity)
end

type creation_options = {
	character: Model?,
	name: string?,
	player: Player?,
	team_id: number?,
}
local function entity_create(options: creation_options): entity
	entity_id += 1

	local entity: entity = {
		character = options.character or nil,
		id = entity_id,
		is_bot = options.player ~= nil,
		name = options.name or nil,
		player = options.player or nil,
		team_id = options.team_id or nil,
	}

	entity_add(entity)

	if is_server == true then
		replication.replicate_create(class_placeholder, entity)
	end

	return entity
end

local function get_character(entity: entity): Model?
	if entity.character ~= nil then
		return entity.character
	end

	if entity.player ~= nil then
		if entity.player.Character ~= nil then
			return entity.player.Character
		end
	end

	return nil
end

local function find_by_character(character: Model): entity?
	for _, entity in all_entities do
		local some_character = get_character(entity)
		if some_character == character then
			return entity
		end
	end

	return nil
end

local function find_by_id(id: number): entity?
	for _, entity in all_entities do
		if entity.id == id then
			return entity
		end
	end

	return nil
end

local function find_by_player(player: Player): entity?
	for _, entity in all_entities do
		if entity.player == player then
			return entity
		end
	end

	return nil
end

local function get_name(entity: entity): string?
	if entity.name ~= nil then
		return entity.name
	end

	if entity.player ~= nil then
		return entity.player.Name
	end

	return nil
end

local function get_textual_reference(entity: entity): string
	local name = get_name(entity)
	if name ~= nil then
		return `"{name}"`
	end

	return `of id {entity.id}`
end

local function entity_destroy(entity: entity): ()
	local index = table.find(all_entities, entity)
	table.remove(all_entities, index)

	if is_server then
		replication.replicate_destroy(class_placeholder, entity.id)
	end

	table.clear(entity)
	local husk: {[any]: any} = entity
	husk["Huh?"] = "Was formerly an entity."
end

--- @client
local function receive_replication(event: replication_event): ()
	if event.kind == "create" then
		entity_add(event.object)
	elseif event.kind == "update" then
		local object_id = event.object_id
		local property_id = event.property_id
		local property_value = event.property_value

		local entity = find_by_id(object_id)
		if entity == nil then
			debug_print(`Error: No entity was found with id {object_id}.`)
			return
		end

		local property_index = properties[property_id]
		if property_index == nil then
			debug_print(`Error: No property was found with id {property_id}.`)
			return
		end

		entity[property_index] = property_value
	elseif event.kind == "destroy" then
		local entity = find_by_id(event.object_id)
		if entity == nil then
			debug_print(`Error: No entity was found with id {event.object_id}.`)
			return
		end

		entity_destroy(entity)
	else
		debug_print(`Unknown replication event kind "{event.kind}".`)
	end
end

local entity_mod: replication.class_module = {
	all_entities = all_entities,
	class_id = class_id,
	create = entity_create,
	destroy = entity_destroy,
	find_by_character = find_by_character,
	find_by_id = find_by_id,
	find_by_player = find_by_player,
	get_character = get_character,
	get_textual_reference = get_textual_reference,
	properties = properties,
	property_map = property_name_to_id,
	replication_receiver = receive_replication,
}
class_placeholder = entity_mod

replication.register_class(entity_mod)

return entity_mod
