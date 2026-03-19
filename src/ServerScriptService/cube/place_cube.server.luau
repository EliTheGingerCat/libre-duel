local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local add_cooldown = require(ReplicatedStorage.modules.cooldown.add_cooldown)
local create_cube = require(ReplicatedStorage.modules.cube.create_cube)
local cube_cache = require(ReplicatedStorage.modules.cube.cube_cache)
local cube_in_hitbox = require(ReplicatedStorage.modules.cube.cube_in_hitbox)
local debug_print = require(ServerScriptService.util.debug_print)
local get_player_cps = require(ServerScriptService.mitigation.get_player_cps)
local get_player_position = require(ReplicatedStorage.modules.player.get_player_position)
local is_on_cooldown = require(ReplicatedStorage.modules.cooldown.is_on_cooldown)
local mitigation_config = require(ServerScriptService.mitigation.mitigation_config)
local play_sound = require(ServerScriptService.util.play_sound)
local player_range_server = require(ServerScriptService.combat.player_range_server)
local snap_coordinate = require(ReplicatedStorage.modules.cube.snap_coordinate)

local function verify_coordinate(coordinate: number): boolean
	return coordinate == snap_coordinate(coordinate)
end

local function verify_position(position: Vector3): boolean
	return (
		    verify_coordinate(position.X)
		and verify_coordinate(position.Y)
		and verify_coordinate(position.Z)
	)
end

local function on_invoke(player: Player, cube_position: unknown): boolean
	if typeof(cube_position) ~= "Vector3" then
		debug_print("Invalid arguments.")
		return false
	end

	local player_position = get_player_position(player)
	if player_position == nil then
		debug_print("Player has no position.")
		return false
	end

	local distance = (cube_position - player_position).Magnitude
	if distance > player_range_server then
		debug_print("Too far.")
		return false
	end

	if not verify_position(cube_position) then
		debug_print("Invalid position.")
		return false
	end

	local occupied_cube = cube_cache[cube_position]
	if occupied_cube then
		debug_print("Occupied by cube.")
		return false
	end

	local occupied_player = cube_in_hitbox(cube_position, player)
	if occupied_player then
		debug_print("Occupied by player.")
		return false
	end

	if is_on_cooldown(player, "place_cube_mitigation") then
		debug_print("Player is mitigated.")
	end

	if get_player_cps(player) >= mitigation_config.cps_treshold and math.random(1, 100) <= mitigation_config.rejection_chance then
		add_cooldown(player, "place_cube_mitigation", mitigation_config.duration)
		return
	end

	cube_cache[cube_position] = true

	local clone = create_cube()
	clone.Position = cube_position
	clone.Parent = workspace
	play_sound("cube_place", cube_position)

	return true
end

ReplicatedStorage.remotes.place_cube.OnServerInvoke = on_invoke
