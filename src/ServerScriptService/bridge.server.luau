local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Teams = game:GetService("Teams")

local colours = require(ReplicatedStorage.modules.colours)
local debug_print = require(script.Parent.modules.debug_print)

type team = {
	cage: Model,
	goal: Part,
	players: {Player},
	points: number,
	spawn_part: Part,
	Roblox_team: Team,
}

type state = {
	cages_are_closed: boolean,
	score_debounce: boolean,
	teams: {team},
}

local active = false
local cage_time = 3
local current_state: state? = nil
local total_players = #Players:GetPlayers()
local win_points = 5

local team_colours = {
	colours.red,
	colours.blue,
}

local Color3_to_BrickColor = {
	[colours.blue] = BrickColor.Blue(),
	[colours.red] = BrickColor.Red(),
}

local function move_player(player: Player, position: Vector3): ()
	local character = player.Character
	if character == nil then
		return
	end

	local root_part = character:FindFirstChild("HumanoidRootPart")
	if root_part == nil then
		return
	end

	if not root_part:IsA("BasePart") then
		return
	end

	root_part.Position = position
end

local function open_cages(state: state): ()
	state.cages_are_closed = true

	for _, team in state.teams do
		team.cage.Parent = nil
	end
end

local function close_cages(state: state): ()
	state.cages_are_closed = true

	for _, team in state.teams do
		team.cage.Parent = workspace

		local spawn_location = team.spawn_part.Position

		for _, player in team.players do
			move_player(player, spawn_location)
		end
	end
end

local function close_then_open_cages(state: state): ()
	close_cages(state)
	task.delay(cage_time, open_cages, state)
end

local function debounce_score_yield(state: state): ()
	state.score_debounce = true
	task.wait(1)
	state.score_debounce = false
end

local function debounce_score(state: state): ()
	task.spawn(debounce_score_yield, state)
end

-- GameStop
local function game_stop(state: state): ()
	if active == true then
		debug_print("Can not stop since the game is not running.")
		return
	end

	for _, team in state.teams do

		-- i don't really know why roblox doesn't set the team color back when the team is destroyed.
		for _, player in team.players do
			if player.Parent then
				player.TeamColor = BrickColor.new("White")
			end
		end

		team.cage:Destroy()
		team.goal:Destroy()
		team.spawn_part:Destroy()
		team.Roblox_team:Destroy()
	end
end

local function process_goal(state: state, team: team): ()
	debounce_score(state)
	team.points += 1

	if team.points >= win_points then
		debug_print(`Team "{team.Roblox_team.Name}" wins.`)
		game_stop(state)
		return
	else
		debug_print(`Team "{team.Roblox_team.Name}" scored. They have {team.points} points.`)
	end

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

		local team: team = {
			cage = cage,
			goal = goal,
			players = {},
			points = 0,
			spawn_part = spawn_part,
			Roblox_team = Roblox_team,
		}

		table.insert(teams, team)
	end

	local state: state = {
		cages_are_closed = false,
		score_debounce = false,
		teams = teams,
	}

	return state
end

-- Maybe this should be merged into `create_map`.
local function setup_map(state: state): ()
	for _, team in state.teams do
		local function on_touched(toucher: BasePart): ()
			if state.score_debounce then
				return
			end

			local character = toucher.Parent
			if character == nil then
				return
			end

			local humanoid = character:FindFirstChildOfClass("Humanoid")
			if humanoid == nil then
				return
			end

			local player = Players:GetPlayerFromCharacter(character)
			if player == nil then
				return
			end

			local player_team = player.Team
			if player_team == team.Roblox_team then
				return
			end

			process_goal(state, team)
		end

		team.goal.Touched:Connect(on_touched)
	end
end

local function setup_player(state: state, player: Player, team: team): ()
	table.insert(team.players, player)
	player.Team = team.Roblox_team

	local function on_character_loaded(): ()
		if state.cages_are_closed then
			move_player(player, team.spawn_part.Position)
		end
	end

	player.CharacterAppearanceLoaded:Connect(on_character_loaded)
end

local function setup_initial_players(state: state, players: {Player}): ()
	local index_player = 0
	local size_players = #players
	local index_team = 0
	local size_teams = #state.teams

	while true do
		index_player += 1
		if index_player > size_players then
			return
		end
		local player = players[index_player]

		index_team += 1
		index_team = (index_team - 1) % size_teams + 1
		local team = state.teams[index_team]

		setup_player(state, player, team)
	end
end

local function game_start(players: {Player}): ()
	if active == true then
		debug_print("Can not start since the game is already running.")
		return
	end

	local state = create_map(2)
	setup_map(state)
	setup_initial_players(state, players)
	close_then_open_cages(state)
end

local function get_smallest_team(state: state): team
	local smallest_count = math.huge
	local smallest_teams: {team} = {}

	for _, team in state.teams do
		local count = #team.players
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

local function add_new_player(state: state, player: Player): ()
	local team = get_smallest_team(state)
	setup_player(state, player, team)

	if state.cages_are_closed then
		move_player(player, team.spawn_part.Position)
	end
end

local function on_players_changed(): ()
	-- This used to be 2, but now it is 1 for testing purposes.
	-- TODO: Add a way to manually start the game.
	if total_players >= 1 then
		if active == false then
			local all_players = Players:GetPlayers()
			task.delay(5, game_start, all_players)
		end
	else
		if active == true then
			assert(current_state, "Current state is missing.")
			game_stop(current_state)
		end
	end
end

local function on_player_added(player: Player): ()
	total_players += 1
	on_players_changed()

	if current_state ~= nil then
		add_new_player(current_state, player)
	end
end
Players.PlayerAdded:Connect(on_player_added)

local function on_player_removing(player: Player): ()
	total_players -= 1
	on_players_changed()
end
Players.PlayerRemoving:Connect(on_player_removing)
