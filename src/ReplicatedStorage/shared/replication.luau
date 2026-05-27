local RunService = game:GetService("RunService")

local debug_print = print
local is_server = RunService:IsServer()

type object = {
	id: number,
	[any]: any,
}

type object_container = {object}

export type team_members_add = {
	kind: "special",
	kind_2: "team_members_add",
	team_id: number,
	addees: {number},
}

export type team_members_remove = {
	kind: "special",
	kind_2: "team_members_remove",
	team_id: number,
	removees: {number},
}

export type replication_event_special = team_members_add | team_members_remove

export type replication_event = {
	kind: "create",

	class_id: number,
	object: object,
} | {
	kind: "update",

	class_id: number,
	object_id: number,
	property_id: number,
	property_value: any,
} | {
	kind: "destroy",

	class_id: number,
	object_id: number,
} | replication_event_special

type replication_receiver = (event: replication_event) -> ()

type class = {
	replication_receiver: replication_receiver,
}

export type class_module = {
	class_id: number,
	properties: {[number]: any},
	replication_receiver: replication_receiver,
	[any]: any,
}

local all_classes: {[number]: class} = {}
local all_replication_events: {replication_event} = {}

--- @server
local function print_server_only(): ()
	debug_print("This function only works on the server.")
end

--- @server
local function replicate_create(class: class_module, object: object): ()
	if is_server == false then
		print_server_only()
		return
	end

	table.insert(all_replication_events, {
		kind = "create",

		class_id = class.class_id,
		object = object,
	})
end

--- @server
local function replicate_update(class: class_module, object: object, property_id: number): ()
	if is_server == false then
		print_server_only()
		return
	end

	local property_index = class.properties[property_id]

	table.insert(all_replication_events, {
		kind = "update",

		class_id = class.class_id,
		object_id = object.id,
		property_id = property_id,
		property_value = object[property_index],
	})
end

--- @server
local function replicate_destroy(class: class_module, object_id: number): ()
	if is_server == false then
		print_server_only()
		return
	end

	table.insert(all_replication_events, {
		kind = "destroy",

		class_id = class.class_id,
		object_id = object_id,
	})
end

local function register_class(class: class_module): ()
	all_classes[class.class_id] = {
		replication_receiver = class.replication_receiver,
	}
end

local replication = {
	all_classes = all_classes,
	all_replication_events = all_replication_events,
	register_class = register_class,

	-- @server
	replicate_create = replicate_create,
	replicate_destroy = replicate_destroy,
	replicate_update = replicate_update,
}

return replication
