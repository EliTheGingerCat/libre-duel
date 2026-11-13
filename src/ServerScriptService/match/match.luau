const ReplicatedStorage = game:GetService("ReplicatedStorage")
const ServerScriptService = game:GetService("ServerScriptService")
const ServerStorage = game:GetService("ServerStorage")
const Workspace = game:GetService("Workspace")

const award_mode_stat = require(ServerScriptService.player_data.awarding.award_mode_stat)
const CUBE_SIZE = require(ReplicatedStorage.shared.cube.CUBE_SIZE)
const GAME_STATS = require(ReplicatedStorage.shared.modes.GAME_STATS)
const MODE_DEFINITIONS = require(ReplicatedStorage.shared.modes.MODE_DEFINITIONS)
const registry = require(ReplicatedStorage.shared.entity.registry)
const show_title_to = require(ServerScriptService.util.show_title)

-- What a mode implements. `start` receives the initial entities grouped by team, while `entity_added` is only for entities that join afterwards.
export type hooks = {
	start: (teams: { { registry.entity } }) -> (),
	entity_added: (entity: registry.entity) -> (),
	entity_removed: (entity: registry.entity) -> (),
	entity_died: ((entity: registry.entity) -> ())?,
	stop: () -> (),
}

export type match = {
	id: number,
	definition: MODE_DEFINITIONS.definition,
	entities: { registry.entity },
	slot: number,
	map: Instance?,
	cubes: { [BasePart]: true? },
	hooks: hooks?,
	stopped: boolean,
	stop_callbacks: { () -> () },
}

export type mode = {
	new: (match: match) -> hooks,
}

-- A multiple of the cube size keeps every slot on the cube grid.
const SLOT_SPACING = CUBE_SIZE * 1000

const entity_matches: { [registry.entity]: match? } = {}
const cube_matches: { [BasePart]: match? } = {}
const slots: { [number]: match? } = {}
-- A stopped match leaves its map and cubes standing until its slot is needed again.
const remains: { [number]: match? } = {}
local last_id = 0

local stop: (match: match) -> ()

local function get_match_of(entity: registry.entity): match?
	return entity_matches[entity]
end

local function get_match_of_cube(cube: BasePart): match?
	return cube_matches[cube]
end

local function fire_all(match: match, remote: RemoteEvent, ...: unknown): ()
	for _, entity in match.entities do
		registry.fire_client(entity, remote, ...)
	end
end

local function show_title(
	match: match,
	fade_in: number,
	stay: number,
	fade_out: number,
	top_text: string,
	bottom_text: string?,
	colour: Color3?
): ()
	for _, entity in match.entities do
		const player = registry.get_player(entity)
		if player then
			show_title_to(player, fade_in, stay, fade_out, top_text, bottom_text, colour)
		end
	end
end

local function award(match: match, entity: registry.entity, stat: GAME_STATS.stat, increment: number?): ()
	award_mode_stat(entity, match.definition.id, stat, increment)
end

local function on_stop(match: match, callback: () -> ()): ()
	table.insert(match.stop_callbacks, callback)
end

local function register(match: match, entity: registry.entity): ()
	entity_matches[entity] = match
	table.insert(match.entities, entity)
	registry.fire_client(entity, ReplicatedStorage.remotes.game_is_active, true)
end

local function unregister(match: match, entity: registry.entity): ()
	entity_matches[entity] = nil
	const index = table.find(match.entities, entity)
	if index then
		table.remove(match.entities, index)
	end
	registry.fire_client(entity, ReplicatedStorage.remotes.game_is_active, false)
end

local function add_entity(match: match, entity: registry.entity): ()
	const hooks = match.hooks
	if match.stopped or hooks == nil or entity_matches[entity] ~= nil then
		return
	end
	register(match, entity)
	hooks.entity_added(entity)
end

local function remove_entity(match: match, entity: registry.entity): ()
	if entity_matches[entity] ~= match then
		return
	end
	if match.hooks then
		match.hooks.entity_removed(entity)
	end
	unregister(match, entity)
	if #match.entities == 0 then
		stop(match)
	end
end

local function clear_remains(slot: number): ()
	const old = remains[slot]
	if old == nil then
		return
	end
	remains[slot] = nil
	if old.map then
		old.map:Destroy()
		old.map = nil
	end
	for cube in old.cubes do
		cube:Destroy()
	end
end

local function take_slot(match: match): number
	local slot = 0
	while slots[slot] ~= nil do
		slot += 1
	end
	slots[slot] = match
	clear_remains(slot)
	return slot
end

local function create(definition: MODE_DEFINITIONS.definition): match
	last_id += 1
	const match: match = {
		id = last_id,
		definition = definition,
		entities = {},
		slot = 0,
		cubes = {},
		stopped = false,
		stop_callbacks = {},
	}
	match.slot = take_slot(match)
	return match
end

local function start(match: match, hooks: hooks, teams: { { registry.entity } }): ()
	assert(match.hooks == nil and not match.stopped, "Match has already been started.")
	match.hooks = hooks
	for _, entities in teams do
		for _, entity in entities do
			assert(entity_matches[entity] == nil, "Entity is already in a match.")
			register(match, entity)
		end
	end
	hooks.start(teams)
end

function stop(match: match): ()
	if match.stopped then
		return
	end
	match.stopped = true
	if match.hooks then
		match.hooks.stop()
	end
	for _, callback in match.stop_callbacks do
		callback()
	end
	for _, entity in table.clone(match.entities) do
		unregister(match, entity)
	end
	slots[match.slot] = nil
	remains[match.slot] = match
end

local function move(instance: Instance, offset: Vector3): ()
	if instance:IsA("PVInstance") then
		instance:PivotTo(instance:GetPivot() + offset)
		return
	end
	for _, child in instance:GetChildren() do
		move(child, offset)
	end
end

-- Maps are stored where slot 0 plays them, so every other slot is that position shifted along X.
local function load_map(match: match): Instance
	const folder = ServerStorage.maps:FindFirstChild(match.definition.game)
	assert(folder, `No maps folder for "{match.definition.game}"`)
	const maps = folder:GetChildren()
	assert(#maps > 0, `No maps available for "{match.definition.game}"`)
	const map = maps[math.random(1, #maps)]:Clone()
	if match.slot ~= 0 then
		move(map, Vector3.new(match.slot * SLOT_SPACING, 0, 0))
	end
	if match.map then
		match.map:Destroy()
	end
	match.map = map
	map.Parent = Workspace
	return map
end

local function track_cube(match: match, cube: BasePart): ()
	local function on_destroying(): ()
		match.cubes[cube] = nil
		cube_matches[cube] = nil
	end
	match.cubes[cube] = true
	cube_matches[cube] = match
	cube.Destroying:Once(on_destroying)
end

local function on_entity_died(_character: Model, entity: registry.entity): ()
	const match = entity_matches[entity]
	const hooks = if match then match.hooks else nil
	if hooks and hooks.entity_died then
		hooks.entity_died(entity)
	end
end

local function on_entity_removed(entity: registry.entity): ()
	const match = entity_matches[entity]
	if match then
		remove_entity(match, entity)
	end
end

local function stop_all(): ()
	for _, match in table.clone(slots) do
		if match then
			stop(match)
		end
	end
end

registry.died:Connect(on_entity_died)
registry.removed:Connect(on_entity_removed)
game:BindToClose(stop_all)

return {
	add_entity = add_entity,
	award = award,
	create = create,
	fire_all = fire_all,
	get_match_of = get_match_of,
	get_match_of_cube = get_match_of_cube,
	load_map = load_map,
	on_stop = on_stop,
	remove_entity = remove_entity,
	show_title = show_title,
	start = start,
	stop = stop,
	track_cube = track_cube,
}
