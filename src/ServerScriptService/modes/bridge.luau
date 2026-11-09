const Players = game:GetService("Players")
const ReplicatedStorage = game:GetService("ReplicatedStorage")
const RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
const ServerStorage = game:GetService("ServerStorage")
const Teams = game:GetService("Teams")
const Workspace = game:GetService("Workspace")

local show_title = require(ServerScriptService.util.show_title)
const COLOURS = require(ReplicatedStorage.shared.ui.COLOURS)
const MODE_DEFINITIONS = require(ReplicatedStorage.shared.modes.MODE_DEFINITIONS)
const debug_print = require(script.Parent.Parent.util.debug_print)
const inventory_types = require(ReplicatedStorage.shared.inventory.inventory_types)
const inventory_util = require(script.Parent.Parent.inventory.inventory_util)
const map_data = require(ReplicatedStorage.shared.maps.map_data)
const match_session = require(script.Parent.Parent.queue.match_session)
const registry = require(ReplicatedStorage.shared.entity.registry)

const LOADOUT: { [number]: inventory_types.item_id } = {
	[1] = "sword",
	[2] = "pickaxe",
	-- where the team clay will go (i couldn't think of anything better :broken_heart:)
	[4] = "bow",
	[5] = "cake",
}
const LOADOUT_AMOUNTS: { [inventory_types.item_id]: number } = {
	cake = 8,
	clay = math.huge,
}
const CLAY_SLOT = 3
const TEAM_CLAYS = { "red_clay", "blue_clay" } -- team1, team2

type team = {
	cage: Instance,
	index: number,
	goal: BasePart,
	name: string,
	entities: { registry.entity },
	points: number,
	spawn_part: BasePart,
	Roblox_team: Team,
}

type state = {
	map: Instance,
	map_name: string,
	cages_are_closed: boolean,
	connections: { RBXScriptConnection },
	character_connection: registry.connection?,
	inventory_connection: registry.connection?,
	teams: { team },
}

local active = false
const CAGE_TIME = 3
local current_definition: MODE_DEFINITIONS.definition? = nil
local current_state: state? = nil
local loaded_map: Instance? = nil
const WIN_POINTS = 5

const TEAM_COLOURS = {
	COLOURS.red,
	COLOURS.blue,
}

const COLOUR3_TO_BRICKCOLOUR = {
	[COLOURS.blue] = BrickColor.new("Bright blue"),
	[COLOURS.red] = BrickColor.new("Bright red"),
}

local function find_team_by_entity(state: state, entity: registry.entity): team?
	for _, team in state.teams do
		if table.find(team.entities, entity) then
			return team
		end
	end
	return nil
end

local function get_opposing_team(state: state, team: team): team
	return state.teams[team.index % #state.teams + 1]
end

-- EliTheGingerCat: I do not like how there are so many overloads for `CFrame.new`.
local function CFrame_from_position(position: Vector3): CFrame
	return CFrame.new(position)
end

local function move_entity(entity: registry.entity, position: Vector3): ()
	const character = registry.get_character(entity)
	if character == nil then
		return
	end

	const current_pivot = character:GetPivot()
	const current_rotation = current_pivot.Rotation
	const new_position_frame = CFrame_from_position(position)
	const new_pivot = new_position_frame * current_rotation

	character:PivotTo(new_pivot)
end

local function open_cages(state: state): ()
	for _, team in state.teams do
		team.cage.Parent = nil
	end

	state.cages_are_closed = false
end

local function close_cages(state: state): ()
	state.cages_are_closed = true

	for _, team in state.teams do
		team.cage.Parent = state.map

		const spawn_location = team.spawn_part.Position

		for _, entity in team.entities do
			move_entity(entity, spawn_location)
		end
	end
end

local function close_then_open_cages(state: state, scoring_team: team?): ()
	if current_state ~= state then
		return
	end
	close_cages(state)
	local function open_current_cages(): ()
		if current_state == state then
			for i = CAGE_TIME, 1, -1 do
				show_title(
					"all",
					0.5,
					2,
					0.5,
					if scoring_team then `{scoring_team.name} SCORED!` else `Opening cages in {i}...`,
					if scoring_team then `Opening cages in {i}...` else nil,
					if scoring_team then TEAM_COLOURS[scoring_team.index] else Color3.fromRGB(255, 255, 255)
				)
				task.wait(1)
			end
			open_cages(state)
		end
	end
	task.spawn(open_current_cages)
end

-- GameStop
local function game_stop(state: state): ()
	if active == false then
		debug_print("Can not stop since the game is not running.")
		return
	end
	active = false
	current_state = nil
	if state.character_connection then
		state.character_connection:Disconnect()
	end
	if state.inventory_connection then
		state.inventory_connection:Disconnect()
	end
	for _, connection in state.connections do
		connection:Disconnect()
	end

	ReplicatedStorage.remotes.game_is_active:FireAllClients(false)

	for _, team in state.teams do
		for _, entity in team.entities do
			registry.set_team(entity, nil)
		end

		team.cage:Destroy()
		team.Roblox_team:Destroy()
	end
	match_session.finish()
end

local function process_goal(state: state, entity: registry.entity, team: team): ()
	team.points += 1

	if type(entity) ~= "string" then
		ReplicatedStorage.remotes.score_self:FireClient(entity)
	end

	if team.points >= WIN_POINTS then
		show_title(
					"all",
					0.5,
					2,
					0.5,
					`{team.name} WON!`,
					`{team.points} - {get_opposing_team(state, team).points}`,
					TEAM_COLOURS[team.index]
				)
		debug_print(`Team "{team.name}" wins.`)
		game_stop(state)
		return
	else
		debug_print(`Team "{team.name}" scored. They have {team.points} points.`)
		ReplicatedStorage.remotes.score_team:FireAllClients(team.index)
	end

	-- ~ investigate: It might be too slow to only set `cages_are_closed` at this point, since `cages_are_closed` is also used to debounce scoring.
	close_then_open_cages(state, team)
end

local function create_map(): state
	const maps = ServerStorage.maps.bridge:GetChildren()
	assert(#maps > 0, "No Bridge maps available")
	const map = maps[math.random(1, #maps)]:Clone()
	const info_module = map:FindFirstChild("MAP_INFO")
	assert(info_module and info_module:IsA("ModuleScript"), "Map is missing MAP_INFO")
	const load_info: (ModuleScript) -> map_data.map_data = require
	const info = load_info(info_module)
	const teams: { team } = {}

	for index, data in { info.TEAM1, info.TEAM2 } do
		const colour = TEAM_COLOURS[index]
		const Roblox_team = Instance.new("Team")
		Roblox_team.TeamColor = COLOUR3_TO_BRICKCOLOUR[colour]
		Roblox_team.Name = `team #{index}`
		Roblox_team.Parent = Teams

		data.SPAWN.Transparency = 1
		data.SPAWN.CanCollide = false
		data.GOAL.CanCollide = false

		teams[index] = {
			cage = data.CAGE,
			index = index,
			goal = data.GOAL,
			name = `team #{index}`,
			entities = {},
			points = 0,
			spawn_part = data.SPAWN,
			Roblox_team = Roblox_team,
		}
	end

	if loaded_map then
		loaded_map:Destroy()
	end
	loaded_map = map
	map.Parent = Workspace

	return {
		map = map,
		map_name = info.MAP_NAME,
		cages_are_closed = false,
		connections = {},
		teams = teams,
	}
end

-- Maybe this should be merged into `create_map`.
local function setup_map(state: state): ()
	for _, team in state.teams do
		local function on_touched(toucher: BasePart): ()
			if current_state ~= state or state.cages_are_closed == true then
				return
			end

			const character = toucher:FindFirstAncestorOfClass("Model")
			if character == nil then
				return
			end

			const humanoid = character:FindFirstChildOfClass("Humanoid")
			if humanoid == nil or humanoid.Health <= 0 then
				return
			end

			const entity = registry.from_character(character)
			if entity == nil then
				return
			end

			const scoring_team = find_team_by_entity(state, entity)
			if scoring_team == nil or scoring_team == team then
				return
			end

			process_goal(state, entity, scoring_team)
		end

		local function on_heartbeat(): ()
			const overlap_parameters = OverlapParams.new()
			-- ~ investigate: For some reason, collision group seems to not be respected.
			overlap_parameters.CollisionGroup = "hitbox"

			const hitboxes = Workspace:GetPartBoundsInBox(team.goal.CFrame, team.goal.Size, overlap_parameters)

			for _, hitbox in hitboxes do
				on_touched(hitbox)
			end
		end

		table.insert(state.connections, RunService.Heartbeat:Connect(on_heartbeat))
	end
end

local function give_match_loadout(entity: registry.entity, team: team): ()
	const inventory = inventory_util.get_inventory(entity)
	if inventory then
		inventory_util.clear_inventory(inventory)
		inventory_util.give_loadout(inventory, LOADOUT, LOADOUT_AMOUNTS)
		--TODO: find a better approach for this. Even though the player *just* spawned, I don't know how I feel about directly overriding a slot.
		inventory[CLAY_SLOT] = { item_id = TEAM_CLAYS[team.index], amount = LOADOUT_AMOUNTS.clay }
		inventory_util.replicate(entity)
	end
end

local function setup_entity(state: state, entity: registry.entity, team: team): ()
	if find_team_by_entity(state, entity) ~= nil then
		return
	end
	table.insert(team.entities, entity)
	registry.set_team(entity, team.Roblox_team)
	move_entity(entity, team.spawn_part.Position)
	give_match_loadout(entity, team)
end

local function setup_initial_entities(state: state, entities: { registry.entity }): ()
	for index, entity in entities do
		const team = state.teams[(index - 1) % #state.teams + 1]
		setup_entity(state, entity, team)
	end
end

local function get_smallest_team(state: state): team
	local smallest_count = math.huge
	const smallest_teams: { team } = {}
	for _, team in state.teams do
		const count = #team.entities
		if count < smallest_count then
			smallest_count = count
			table.clear(smallest_teams)
		end
		if count == smallest_count then
			table.insert(smallest_teams, team)
		end
	end
	return smallest_teams[math.random(1, #smallest_teams)]
end

local function game_start(entities: { registry.entity }, roster: match_session.roster?): ()
	if active == true then
		debug_print("Can not start since the game is already running.")
		return
	end

	const state = create_map()
	ReplicatedStorage.remotes.game_is_active:FireAllClients(true)
	ReplicatedStorage.remotes.map_name:FireAllClients(state.map_name)

	active = true
	current_state = state
	setup_map(state)
	local function on_character_added(_character: Model, entity: registry.entity): ()
		const team = find_team_by_entity(state, entity)
		if team then
			move_entity(entity, team.spawn_part.Position)
		end
	end
	state.character_connection = registry.character_added:Connect(on_character_added)
	-- not character_added, signals fire newest first so the inventory wouldn't exist yet
	local function on_inventory_created(entity: registry.entity): ()
		const team = find_team_by_entity(state, entity)
		if team then
			give_match_loadout(entity, team)
		end
	end
	state.inventory_connection = inventory_util.created:Connect(on_inventory_created)
	if roster then
		for index, team in state.teams do
			for _, user_id in roster[`team{index}`] do
				const player = Players:GetPlayerByUserId(user_id)
				if player then
					setup_entity(state, player, team)
				end
			end
		end
		for _, entity in entities do
			if type(entity) == "string" then
				setup_entity(state, entity, get_smallest_team(state))
			end
		end
	else
		setup_initial_entities(state, entities)
	end
	close_then_open_cages(state)
end

local function on_match_ready(): ()
	const roster = match_session.get_roster()
	if roster then
		game_start(registry.get_all(), roster)
	end
end

local start_pending = false
local enabled = false
local start_thread: thread? = nil
local added_connection: registry.connection? = nil
local removed_connection: registry.connection? = nil
local ready_connection: RBXScriptConnection? = nil

local function start_studio_match(): ()
	start_thread = nil
	start_pending = false
	if not enabled then
		return
	end
	const entities = registry.get_all()
	if not active and #entities > 0 then
		game_start(entities, nil)
	end
end

local function on_entities_changed(): ()
	if not RunService:IsStudio() then
		return
	end
	if #registry.get_all() > 0 then
		if not active and not start_pending then
			start_pending = true
			start_thread = task.delay(5, start_studio_match)
		end
	elseif current_state then
		game_stop(current_state)
	end
end

local function on_entity_added(entity: registry.entity): ()
	const state = current_state
	if state and (RunService:IsStudio() or type(entity) == "string") then
		setup_entity(state, entity, get_smallest_team(state))
	end
	on_entities_changed()
end

local function on_entity_removed(entity: registry.entity): ()
	const state = current_state
	if state then
		const team = find_team_by_entity(state, entity)
		if team then
			const index = table.find(team.entities, entity)
			if index then
				table.remove(team.entities, index)
			end
		end
	end
	on_entities_changed()
end

local function start(definition: MODE_DEFINITIONS.definition): ()
	if enabled then
		return
	end
	enabled = true
	current_definition = definition
	added_connection = registry.added:Connect(on_entity_added)
	removed_connection = registry.removed:Connect(on_entity_removed)

	if RunService:IsStudio() then
		on_entities_changed()
	else
		ready_connection = match_session.ready:Connect(on_match_ready)
		on_match_ready()
	end
end

local function stop(): ()
	enabled = false
	current_definition = nil
	if start_thread then
		task.cancel(start_thread)
		start_thread = nil
	end
	start_pending = false
	if added_connection then
		added_connection:Disconnect()
		added_connection = nil
	end
	if removed_connection then
		removed_connection:Disconnect()
		removed_connection = nil
	end
	if ready_connection then
		ready_connection:Disconnect()
		ready_connection = nil
	end
	if current_state then
		game_stop(current_state)
	end
end

return {
	studio = true,
	start = start,
	stop = stop,
}
