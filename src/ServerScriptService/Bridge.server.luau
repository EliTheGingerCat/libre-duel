const Players = game:GetService("Players")
const ReplicatedStorage = game:GetService("ReplicatedStorage")
const RunService = game:GetService("RunService")
const Teams = game:GetService("Teams")
const Workspace = game:GetService("Workspace")

const COLOURS = require(ReplicatedStorage.shared.ui.COLOURS)
const debug_print = require(script.Parent.util.debug_print)
const match_session = require(script.Parent.queue.match_session)
const registry = require(ReplicatedStorage.shared.entity.registry)

type team = {
	cage: Model,
	index: number,
	goal: Part,
	name: string,
	entities: { registry.entity },
	points: number,
	spawn_part: Part,
	Roblox_team: Team,
}

type state = {
	cages_are_closed: boolean,
	connections: { RBXScriptConnection },
	character_connection: registry.connection?,
	teams: { team },
}

local active = false
const CAGE_TIME = 3
local current_state: state? = nil
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
		team.cage.Parent = workspace

		const spawn_location = team.spawn_part.Position

		for _, entity in team.entities do
			move_entity(entity, spawn_location)
		end
	end
end

local function close_then_open_cages(state: state): ()
	if current_state ~= state then
		return
	end
	close_cages(state)
	local function open_current_cages(): ()
		if current_state == state then
			open_cages(state)
		end
	end
	task.delay(CAGE_TIME, open_current_cages)
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
	for _, connection in state.connections do
		connection:Disconnect()
	end

	ReplicatedStorage.remotes.game_is_active:FireAllClients(false)

	for _, team in state.teams do
		for _, entity in team.entities do
			registry.set_team(entity, nil)
		end

		team.cage:Destroy()
		team.goal:Destroy()
		team.spawn_part:Destroy()
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
		debug_print(`Team "{team.name}" wins.`)
		game_stop(state)
		return
	else
		debug_print(`Team "{team.name}" scored. They have {team.points} points.`)
		ReplicatedStorage.remotes.score_team:FireAllClients(team.index)
	end

	-- ~ investigate: It might be too slow to only set `cages_are_closed` at this point, since `cages_are_closed` is also used to debounce scoring.
	close_then_open_cages(state)
end

type spawn_part_properties = {
	colour: Color3,
	position: Vector3,
	name: string,
}
local function create_spawn_part(properties: spawn_part_properties): Part
	const spawn_part = Instance.new("Part")
	spawn_part.Anchored = true
	spawn_part.CanCollide = false
	spawn_part.Color = properties.colour
	spawn_part.Position = properties.position
	spawn_part.Name = properties.name
	spawn_part.Size = Vector3.new(1, 1, 1)
	spawn_part.Transparency = 1
	return spawn_part
end

type cage_properties = {
	colour: Color3,
	position: Vector3,
	name: string,
}
local function create_cage(properties: cage_properties): Model
	const cage_model = Instance.new("Model")
	cage_model.Name = properties.name

	const cage_part = Instance.new("Part")
	cage_part.Anchored = true
	cage_part.Color = properties.colour
	cage_part.Position = properties.position
	cage_part.Size = Vector3.new(9, 3, 9)
	cage_part.Parent = cage_model

	return cage_model
end

type goal_part_properties = {
	colour: Color3,
	position: Vector3,
	name: string,
}
local function create_goal_part(properties: goal_part_properties): Part
	const goal_part = Instance.new("Part")
	goal_part.Anchored = true
	goal_part.Color = properties.colour
	goal_part.Position = properties.position
	goal_part.Name = properties.name
	goal_part.Size = Vector3.new(9, 9, 9)
	return goal_part
end

type Roblox_team_properties = {
	colour: BrickColor,
	name: string,
}
local function create_Roblox_team(properties: Roblox_team_properties): Team
	const Roblox_team = Instance.new("Team")
	Roblox_team.TeamColor = properties.colour
	Roblox_team.Name = properties.name
	return Roblox_team
end

local function create_map(number_teams: number): state
	const teams: { team } = {}

	for iteration = 1, number_teams do
		const colour_index = (iteration - 1) % #TEAM_COLOURS + 1
		const colour = TEAM_COLOURS[colour_index]

		const c_1 = (iteration - 1) * 12
		const c_3 = 0

		const cage_position = Vector3.new(c_1, 15, c_3)
		const spawn_position = cage_position + Vector3.new(0, 6, 0)

		const spawn_part = create_spawn_part({
			colour = colour,
			position = spawn_position,
			name = `team #{iteration}'s spawn`,
		})
		spawn_part.Parent = workspace

		const cage = create_cage({
			colour = colour,
			position = cage_position,
			name = `team #{iteration}'s cage`,
		})
		cage.Parent = workspace

		const goal = create_goal_part({
			colour = colour,
			position = Vector3.new(c_1, 6, c_3),
			name = `team #{iteration}'s goal`,
		})
		goal.Parent = workspace

		const colour_brick = COLOUR3_TO_BRICKCOLOUR[colour]
		const Roblox_team = create_Roblox_team({
			colour = colour_brick,
			name = `team #{iteration}`,
		})
		Roblox_team.Parent = Teams

		const index = #teams + 1

		const team: team = {
			cage = cage,
			index = index,
			goal = goal,
			name = `team #{iteration}`,
			entities = {},
			points = 0,
			spawn_part = spawn_part,
			Roblox_team = Roblox_team,
		}

		teams[index] = team
	end

	const state: state = {
		cages_are_closed = false,
		connections = {},
		teams = teams,
	}

	return state
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

local function setup_entity(state: state, entity: registry.entity, team: team): ()
	if find_team_by_entity(state, entity) ~= nil then
		return
	end
	table.insert(team.entities, entity)
	registry.set_team(entity, team.Roblox_team)
	move_entity(entity, team.spawn_part.Position)
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

	ReplicatedStorage.remotes.game_is_active:FireAllClients(true)
	ReplicatedStorage.remotes.map_name:FireAllClients("test")

	local team_count = 2
	if roster then
		team_count = 0
		for _ in roster do
			team_count += 1
		end
	end
	const state = create_map(team_count)
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

local function start_studio_match(): ()
	start_pending = false
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
			task.delay(5, start_studio_match)
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

registry.added:Connect(on_entity_added)
registry.removed:Connect(on_entity_removed)

if RunService:IsStudio() then
	on_entities_changed()
else
	match_session.ready:Connect(on_match_ready)
	on_match_ready()
end
