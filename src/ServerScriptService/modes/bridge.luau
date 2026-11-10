const ReplicatedStorage = game:GetService("ReplicatedStorage")
const RunService = game:GetService("RunService")
const ServerScriptService = game:GetService("ServerScriptService")
const Teams = game:GetService("Teams")
const Workspace = game:GetService("Workspace")

const COLOURS = require(ReplicatedStorage.shared.ui.COLOURS)
const debug_print = require(script.Parent.Parent.util.debug_print)
const inventory_types = require(ReplicatedStorage.shared.inventory.inventory_types)
const inventory_util = require(script.Parent.Parent.inventory.inventory_util)
const map_data = require(ReplicatedStorage.shared.maps.map_data)
const match = require(ServerScriptService.match.match)
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

const CAGE_TIME = 3
const WIN_POINTS = 5

const TEAM_COLOURS = {
	COLOURS.red,
	COLOURS.blue,
}

const COLOUR3_TO_BRICKCOLOUR = {
	[COLOURS.blue] = BrickColor.new("Bright blue"),
	[COLOURS.red] = BrickColor.new("Bright red"),
}


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

local function create_teams(info: map_data.map_data): { team }
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

	return teams
end

local function new(this_match: match.match): match.hooks
	const map = match.load_map(this_match)
	const info_module = map:FindFirstChild("MAP_INFO")
	assert(info_module and info_module:IsA("ModuleScript"), "Map is missing MAP_INFO")
	const load_info: (ModuleScript) -> map_data.map_data = require
	const info = load_info(info_module)
	const teams = create_teams(info)
	const connections: { RBXScriptConnection | registry.connection } = {}
	local cages_are_closed = false

	local function find_team_by_entity(entity: registry.entity): team?
		for _, team in teams do
			if table.find(team.entities, entity) then
				return team
			end
		end
		return nil
	end

	local function get_opposing_team(team: team): team
		return teams[team.index % #teams + 1]
	end

	local function get_smallest_team(): team
		local smallest_count = math.huge
		const smallest_teams: { team } = {}
		for _, team in teams do
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

	local function open_cages(): ()
		for _, team in teams do
			team.cage.Parent = nil
		end

		cages_are_closed = false
	end

	local function close_cages(): ()
		cages_are_closed = true

		for _, team in teams do
			team.cage.Parent = map

			const spawn_location = team.spawn_part.Position

			for _, entity in team.entities do
				move_entity(entity, spawn_location)
			end
		end
	end

	local function close_then_open_cages(scoring_team: team?): ()
		if this_match.stopped then
			return
		end
		close_cages()
		local function open_current_cages(): ()
			for i = CAGE_TIME, 1, -1 do
				if this_match.stopped then
					return
				end
				match.show_title(
					this_match,
					0.5,
					2,
					0.5,
					if scoring_team then `{scoring_team.name} SCORED!` else `Opening cages in {i}...`,
					if scoring_team then `Opening cages in {i}...` else nil,
					if scoring_team then TEAM_COLOURS[scoring_team.index] else Color3.fromRGB(255, 255, 255)
				)
				task.wait(1)
			end
			if not this_match.stopped then
				open_cages()
			end
		end
		task.spawn(open_current_cages)
	end

	local function process_goal(entity: registry.entity, team: team): ()
		team.points += 1
		match.award(this_match, entity, "goals")

		if type(entity) ~= "string" then
			ReplicatedStorage.remotes.score_self:FireClient(entity)
		end

		if team.points >= WIN_POINTS then
			const opposing_team = get_opposing_team(team)
			match.show_title(
				this_match,
				0.5,
				2,
				0.5,
				`{team.name} WON!`,
				`{team.points} - {opposing_team.points}`,
				TEAM_COLOURS[team.index]
			)
			debug_print(`Team "{team.name}" wins.`)
			-- Hand out the Dubs
			for _, winner in team.entities do
				match.award(this_match, winner, "wins")
			end
			-- then the Ls...
			for _, loser in opposing_team.entities do
				match.award(this_match, loser, "losses")
			end

			match.stop(this_match)
			return
		else
			debug_print(`Team "{team.name}" scored. They have {team.points} points.`)
			match.fire_all(this_match, ReplicatedStorage.remotes.score_team, team.index)
		end

		-- ~ investigate: It might be too slow to only set `cages_are_closed` at this point, since `cages_are_closed` is also used to debounce scoring.
		close_then_open_cages(team)
	end

	local function watch_goal(team: team): ()
		local function on_touched(toucher: BasePart): ()
			if this_match.stopped or cages_are_closed == true then
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

			const scoring_team = find_team_by_entity(entity)
			if scoring_team == nil or scoring_team == team then
				return
			end

			process_goal(entity, scoring_team)
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

		table.insert(connections, RunService.Heartbeat:Connect(on_heartbeat))
	end

	local function setup_entity(entity: registry.entity, team: team): ()
		if find_team_by_entity(entity) ~= nil then
			return
		end
		table.insert(team.entities, entity)
		registry.set_team(entity, team.Roblox_team)
		move_entity(entity, team.spawn_part.Position)
		give_match_loadout(entity, team)
		if type(entity) ~= "string" then
			ReplicatedStorage.remotes.map_name:FireClient(entity, info.MAP_NAME)
		end
	end

	local function on_character_added(_character: Model, entity: registry.entity): ()
		const team = find_team_by_entity(entity)
		if team then
			move_entity(entity, team.spawn_part.Position)
		end
	end

	-- not character_added, signals fire newest first so the inventory wouldn't exist yet
	local function on_inventory_created(entity: registry.entity): ()
		const team = find_team_by_entity(entity)
		if team then
			give_match_loadout(entity, team)
		end
	end

	local function start(initial_teams: { { registry.entity } }): ()
		assert(#initial_teams <= #teams, "Bridge maps do not have that many teams.")
		for _, team in teams do
			watch_goal(team)
		end
		table.insert(connections, registry.character_added:Connect(on_character_added))
		table.insert(connections, inventory_util.created:Connect(on_inventory_created))
		for index, entities in initial_teams do
			for _, entity in entities do
				setup_entity(entity, teams[index])
			end
		end
		close_then_open_cages()
	end

	local function on_entity_added(entity: registry.entity): ()
		setup_entity(entity, get_smallest_team())
	end

	local function on_entity_removed(entity: registry.entity): ()
		const team = find_team_by_entity(entity)
		if team then
			const index = table.find(team.entities, entity)
			if index then
				table.remove(team.entities, index)
			end
			registry.set_team(entity, nil)
		end
	end

	local function stop(): ()
		for _, connection in connections do
			connection:Disconnect()
		end

		for _, team in teams do
			for _, entity in team.entities do
				registry.set_team(entity, nil)
			end

			team.cage:Destroy()
			team.Roblox_team:Destroy()
		end
	end

	return {
		start = start,
		entity_added = on_entity_added,
		entity_removed = on_entity_removed,
		stop = stop,
	}
end

return {
	new = new,
}
