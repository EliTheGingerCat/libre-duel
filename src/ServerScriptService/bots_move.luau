local PathfindingService = game:GetService("PathfindingService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")

local debug_print = require(ServerScriptService.util.debug_print)
local entity_mod = require(ReplicatedStorage.shared.entity)
local team_mod = require(ReplicatedStorage.shared.team)

type entity = entity_mod.entity

local all_connections: {RBXScriptConnection} = {}
local all_threads: {thread} = {}

local function start_entity(entity: entity): ()
	if entity.is_bot == false then
		return
	end

	local thread_follow: thread? = nil

	local function update_waypoints(): ()
		if thread_follow ~= nil then
			-- Eli: Thus, `all_threads` contains dead threads. I do not think that this is a problem.
			task.cancel(thread_follow)
			thread_follow = nil
		end

		local character = entity_mod.get_character(entity)
		if character == nil then
			debug_print(`Error: Entity {entity_mod.get_textual_reference(entity)}'s character was missing.`)
			return
		end

		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if humanoid == nil then
			debug_print(`Error: Entity {entity_mod.get_textual_reference(entity)}'s humanoid was missing.`)
			return
		end

		local root = character:FindFirstChild("HumanoidRootPart")
		if root == nil then
			debug_print(`Error: Entity {entity_mod.get_textual_reference(entity)}'s root was missing.`)
			return
		end

		if not root:IsA("Part") then
			debug_print(`Error: Entity {entity_mod.get_textual_reference(entity)}'s root is not a part.`)
			return
		end

		local root_position = root.Position
		
		local enemy_goals: {Part} = {}

		for _, team in team_mod.all_teams do
			if team.id == entity.team_id then
				continue
			end

			table.insert(enemy_goals, team.goal)
		end

		local closest_goal: Part? = nil
		local closest_distance = math.huge
		for _, this_goal in enemy_goals do
			local this_displacement = this_goal.Position - root_position
			local this_distance = this_displacement.Magnitude

			if this_distance < closest_distance then
				closest_distance = this_distance
				closest_goal = this_goal
			end
		end

		if closest_goal == nil then
			debug_print("Error: No enemy goals found.")
			return
		end

		local path = PathfindingService:CreatePath()
		path:ComputeAsync(root_position, closest_goal.Position)

		local waypoints = path:GetWaypoints()

		local function follow_waypoints(): ()
			for _, waypoint in waypoints do
				if waypoint.Action == Enum.PathWaypointAction.Walk then
					humanoid:MoveTo(waypoint.Position)
					humanoid.MoveToFinished:Wait()
				end
			end
		end

		local thread_new = task.spawn(follow_waypoints)
		thread_follow = thread_new
		table.insert(all_threads, thread_new)
	end

	local iteration = -1
	local function on_heartbeat(): ()
		iteration += 1
		if iteration % 100 == 0 then
			update_waypoints()
		end
	end

	local connection = RunService.Heartbeat:Connect(on_heartbeat)
	table.insert(all_connections, connection)
end

local function start(): ()
	for _, entity in entity_mod.all_entities do
		start_entity(entity)
	end
	-- ~ Todo: Listen for new entities.
end

local function stop(): ()
	for _, connection in all_connections do
		connection:Disconnect()
	end
	table.clear(all_connections)
	for _, thread in all_threads do
		task.cancel(thread)
	end
	table.clear(all_threads)
end

local bots_move = {
	start = start,
	stop = stop,
}

return bots_move
