local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Teams = game:GetService("Teams")
local Workspace = game:GetService("Workspace")

local colours = require(ReplicatedStorage.shared.ui.colours)
local debug_print = require(script.Parent.util.debug_print)
local entity_mod = require(ReplicatedStorage.shared.entity)
local replication = require(ReplicatedStorage.shared.replication)
local team_mod = require(ReplicatedStorage.shared.team)

type entity = entity_mod.entity
local replicate_update = replication.replicate_update
type team = team_mod.team

type state = {
	cages_are_closed: boolean,
	teams: {team},
}

local active = false
local cage_time = 3
local current_state: state? = nil
local total_entities = #Players:GetPlayers()
local win_points = 5

local team_colours = {
	colours.red,
	colours.blue,
}

local Color3_to_BrickColor = {
	[colours.blue] = BrickColor.new("Bright blue"),
	[colours.red] = BrickColor.new("Bright red"),
}

-- EliTheGingerCat: I do not like how there are so many overloads for `CFrame.new`. 
local function CFrame_from_position(position: Vector3): CFrame
	return CFrame.new(position)
end

local function move_entity(entity: entity, position: Vector3): ()
	local character = entity_mod.get_character(entity)
	if character == nil then
		return
	end

	local current_pivot = character:GetPivot()
	local current_rotation = current_pivot.Rotation
	local new_position_frame = CFrame_from_position(position)
	local new_pivot = new_position_frame * current_rotation

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

		local spawn_location = team.spawn_part.Position

		for _, player in team.members do
			move_entity(player, spawn_location)
		end
	end
end

local function close_then_open_cages(state: state): ()
	close_cages(state)
	task.delay(cage_time, open_cages, state)
end

-- GameStop
local function game_stop(state: state): ()
	if active == true then
		debug_print("Can not stop since the game is not running.")
		return
	end

	ReplicatedStorage.remotes.game_is_active:FireAllClients(false)

	for _, team in state.teams do

		-- i don't really know why roblox doesn't set the team color back when the team is destroyed.
		for _, entity in team.members do
			if entity.player == nil then
				continue
			end
			entity.player.TeamColor = BrickColor.new("White")
		end

		team.cage:Destroy()
		team.goal:Destroy()
		team.spawn_part:Destroy()
		team.Roblox_team:Destroy()
	end
end

local function process_goal(state: state, entity: entity, team: team): ()
	team.points += 1
	replicate_update(team_mod, team, team_mod.property_map.points)

	if entity.player ~= nil then
		ReplicatedStorage.remotes.score_self:FireClient(entity.player)
	end

	if team.points >= win_points then
		debug_print(`Team "{team.name}" wins.`)
		game_stop(state)
		return
	else
		debug_print(`Team "{team.name}" scored. They have {team.points} points.`)
		ReplicatedStorage.remotes.score_team:FireAllClients(team.id)
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
	local spawn_part = Instance.new("Part")
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
	local cage_model = Instance.new("Model")
	cage_model.Name = properties.name

	local cage_part = Instance.new("Part")
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
	local goal_part = Instance.new("Part")
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
	local Roblox_team = Instance.new("Team")
	Roblox_team.TeamColor = properties.colour
	Roblox_team.Name = properties.name
	return Roblox_team
end

local function create_map(number_teams: number): state
	local teams: {team} = {}

	for iteration = 1, number_teams do
		local colour_index = (iteration - 1) % #team_colours + 1
		local colour = team_colours[colour_index]

		local c_1 = (iteration - 1) * 12
		local c_3 = 0

		local cage_position = Vector3.new(c_1, 15, c_3)
		local spawn_position = cage_position + Vector3.new(0, 6, 0)

		local spawn_part = create_spawn_part({
			colour = colour,
			position = spawn_position,
			name = `team #{iteration}'s spawn`,
		})
		spawn_part.Parent = workspace

		local cage = create_cage({
			colour = colour,
			position = cage_position,
			name = `team #{iteration}'s cage`,
		})
		cage.Parent = workspace

		local goal = create_goal_part({
			colour = colour,
			position = Vector3.new(c_1, 6, c_3),
			name = `team #{iteration}'s goal`,
		})
		goal.Parent = workspace

		local colour_brick = Color3_to_BrickColor[colour]
		local Roblox_team = create_Roblox_team({
			colour = colour_brick,
			name = `team #{iteration}`,
		})
		Roblox_team.Parent = Teams

		local index = #teams + 1

		local team = team_mod.create({
			cage = cage,
			index = index,
			goal = goal,
			members = {},
			name = `team #{iteration}`,
			points = 0,
			spawn_part = spawn_part,
			Roblox_team = Roblox_team,
		})

		teams[index] = team
	end

	local state: state = {
		cages_are_closed = false,
		teams = teams,
	}

	return state
end

-- Maybe this should be merged into `create_map`.
local function setup_map(state: state): ()
	for _, team in state.teams do
		local function on_touched(toucher: BasePart): ()
			if state.cages_are_closed == true then
				return
			end

			local humanoid_root = toucher.Parent
			if humanoid_root == nil then
				return
			end

			local character = humanoid_root.Parent
			if character == nil then
				return
			end

			if not character:IsA("Model") then
				return
			end

			local humanoid = character:FindFirstChildOfClass("Humanoid")
			if humanoid == nil then
				return
			end

			local entity = entity_mod.find_by_character(character)
			if entity == nil then
				return
			end

			if entity.team_id == team.id or entity.team_id == nil then
				return
			end

			local scoring_team = team_mod.find_by_id(entity.team_id)
			if scoring_team == nil then
				debug_print(`Error: No team was found with id {entity.team_id}.`)
				return
			end

			process_goal(state, entity, scoring_team)
		end

		local function on_heartbeat(): ()
			local overlap_parameters = OverlapParams.new()
			-- ~ investigate: For some reason, collision group seems to not be respected.
			overlap_parameters.CollisionGroup = "hitbox"

			local hitboxes = Workspace:GetPartBoundsInBox(team.goal.CFrame, team.goal.Size, overlap_parameters)

			for _, hitbox in hitboxes do
				on_touched(hitbox)
			end
		end

		RunService.Heartbeat:Connect(on_heartbeat)
	end
end

local function setup_entity(state: state, entity: entity, team: team): ()
	team_mod.members_add(team, {entity})
	entity.team_id = team.id

	if entity.player ~= nil then
		local function on_character_loaded(): ()
			move_entity(entity, team.spawn_part.Position)
		end

		entity.player.CharacterAdded:Connect(on_character_loaded)
	end
end

local function setup_initial_entities(state: state, entities: {entity}): ()
	local index_entity = 0
	local size_entities = #entities
	local index_team = 0
	local size_teams = #state.teams

	while true do
		index_entity += 1
		if index_entity > size_entities then
			return
		end
		local entity = entities[index_entity]

		index_team += 1
		index_team = (index_team - 1) % size_teams + 1
		local team = state.teams[index_team]

		setup_entity(state, entity, team)
	end
end

local function game_start(entities: {entity}): ()
	if active == true then
		debug_print("Can not start since the game is already running.")
		return
	end

	ReplicatedStorage.remotes.game_is_active:FireAllClients(true)
	ReplicatedStorage.remotes.map_name:FireAllClients("test")

	local state = create_map(2)
	setup_map(state)
	setup_initial_entities(state, entities)
	close_then_open_cages(state)
end

local function get_smallest_team(state: state): team
	local smallest_count = math.huge
	local smallest_teams: {team} = {}

	for _, team in state.teams do
		local count = #team.members
		if count == smallest_count then
			smallest_count = count
			table.clear(smallest_teams)
			table.insert(smallest_teams, team)
		elseif count < smallest_count then
			table.insert(smallest_teams, team)
		end
	end

	local random_smallest_team = smallest_teams[math.random(1, #smallest_teams)]
	return random_smallest_team
end

local function add_new_entity(state: state, entity: entity): ()
	local team = get_smallest_team(state)
	setup_entity(state, entity, team)
	move_entity(entity, team.spawn_part.Position)
end

local function on_entities_changed(): ()
	-- This used to be 2, but now it is 1 for testing purposes.
	-- TODO: Add a way to manually start the game.
	if total_entities >= 1 then
		if active == false then
			local all_entities = entity_mod.all_entities
			task.delay(5, game_start, all_entities)
		end
	else
		if active == true then
			assert(current_state, "Current state is missing.")
			game_stop(current_state)
		end
	end
end

local function on_player_added(player: Player): ()
	local entity = entity_mod.create({
		player = player,
	})
	total_entities += 1
	on_entities_changed()

	if current_state ~= nil then
		add_new_entity(current_state, entity)
	end
end
Players.PlayerAdded:Connect(on_player_added)

local function on_player_removing(player: Player): ()
	local entity = entity_mod.find_by_player(player)
	if entity == nil then
		debug_print(`Error: No entity found for player "{player.Name}".`)
		return
	end

	entity_mod.destroy(entity)
	total_entities -= 1
	on_entities_changed()
end
Players.PlayerRemoving:Connect(on_player_removing)
