local players = game:GetService("Players")
local workspace = game:GetService("Workspace")
local run_service = game:GetService("RunService")

local player = players.LocalPlayer

local edge_fall_prevention = {}

local controls_module = nil
local old_move_function = nil

local update_connection = nil
local camera_connection = nil
local cleanup_connection = nil
local overhang_part = nil

local move_ray_check = RaycastParams.new()
move_ray_check.FilterType = Enum.RaycastFilterType.Exclude

local floor_ray_check = RaycastParams.new()
floor_ray_check.FilterType = Enum.RaycastFilterType.Exclude

local hang_offset = 1.0
local hiding_cframe = CFrame.new(0, -10000, 0)
local overhang_thickness = 0.05

local cached_char, cached_root, cached_hum
local cached_camera = workspace.CurrentCamera
local last_floor_part = nil
local is_enabled = false

local function update_character_cache()
	local char = player.Character
	if char == cached_char then return end

	cached_char = char
	if char then
		cached_root = char:FindFirstChild("HumanoidRootPart")
		cached_hum = char:FindFirstChildOfClass("Humanoid")

		floor_ray_check.FilterDescendantsInstances = {char}
		move_ray_check.FilterDescendantsInstances = {char, cached_camera}
	else
		cached_root = nil
		cached_hum = nil
	end
end

local function get_controls()
	if controls_module then return controls_module end

	local player_scripts = player:WaitForChild("PlayerScripts", 5)
	if player_scripts then
		local player_module = player_scripts:WaitForChild("PlayerModule", 5)
		if player_module then
			local success, result = pcall(function()
				return require(player_module):GetControls()
			end)
			if success then
				controls_module = result
			end
		end
	end

	return controls_module
end

local function is_direction_safe(pos, offset, drop_vec)
	return workspace:Raycast(pos + offset, drop_vec, move_ray_check) ~= nil
end

function edge_fall_prevention.enable()
	if is_enabled then return end
	is_enabled = true

	if cleanup_connection then
		cleanup_connection:Disconnect()
		cleanup_connection = nil
	end

	local controls = get_controls()
	if not controls or old_move_function then return end

	if not overhang_part then
		overhang_part = Instance.new("Part")
		overhang_part.Name = "sneak_overhang"
		overhang_part.Anchored = true
		overhang_part.CanCollide = true
		overhang_part.Transparency = 1
		overhang_part.CastShadow = false
		overhang_part.CustomPhysicalProperties = PhysicalProperties.new(0.0001, 0, 0, 0, 0) --Density has to be 0.0001 so roblox stops crying in the console...
		overhang_part.Parent = workspace
	end

	camera_connection = workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
		cached_camera = workspace.CurrentCamera
		if cached_char then
			move_ray_check.FilterDescendantsInstances = {cached_char, cached_camera}
		end
	end)

	update_connection = run_service.Heartbeat:Connect(function()
		update_character_cache()

		if not (cached_char and cached_root and cached_hum and cached_hum.Health > 0) then return end

		local drop_vec = Vector3.new(0, -cached_hum.HipHeight - 2, 0)
		local ray = workspace:Raycast(cached_root.Position, drop_vec, floor_ray_check)

		if ray and ray.Instance then
			local hit_inst = ray.Instance

			if hit_inst == overhang_part then
				return
			elseif hit_inst:IsA("BasePart") and not hit_inst:IsA("Terrain") then
				if hit_inst ~= last_floor_part then
					last_floor_part = hit_inst
					local floor_size = hit_inst.Size

					overhang_part.Size = Vector3.new(
						floor_size.X + (hang_offset * 2),
						overhang_thickness,
						floor_size.Z + (hang_offset * 2)
					)

					overhang_part.CFrame = hit_inst.CFrame * CFrame.new(0, (floor_size.Y * 0.5) - (overhang_thickness * 0.5), 0)
				end
			end
		end
	end)

	old_move_function = controls.moveFunction

	controls.moveFunction = function(self, vec, face)
		if not (cached_root and cached_hum and cached_hum.Health > 0) or vec.Magnitude == 0 then
			return old_move_function(self, vec, face)
		end

		local is_airborne = (cached_hum.FloorMaterial == Enum.Material.Air)
			or (cached_hum:GetState() == Enum.HumanoidStateType.Freefall)
			or (cached_hum:GetState() == Enum.HumanoidStateType.Jumping)

		if not is_airborne then
			local look_ahead = (cached_hum.WalkSpeed / 60) * 1.5
			local test_vec = vec.Unit * look_ahead
			local drop_vec = Vector3.new(0, -cached_hum.HipHeight - 2, 0)
			local root_pos = cached_root.Position

			if not is_direction_safe(root_pos, test_vec, drop_vec) then
				local v_x, v_z = vec.X, vec.Z
				local abs_x, abs_z = math.abs(v_x), math.abs(v_z)

				local safe_x = abs_x > 0.01 and is_direction_safe(root_pos, Vector3.new(test_vec.X, 0, 0), drop_vec)
				local safe_z = abs_z > 0.01 and is_direction_safe(root_pos, Vector3.new(0, 0, test_vec.Z), drop_vec)

				if safe_x and not safe_z then
					vec = Vector3.new(v_x, 0, 0)
				elseif safe_z and not safe_x then
					vec = Vector3.new(0, 0, v_z)
				elseif safe_x and safe_z then
					if abs_x > abs_z then
						vec = Vector3.new(v_x, 0, 0)
					else
						vec = Vector3.new(0, 0, v_z)
					end
				else
					vec = Vector3.zero
				end
			end
		end

		return old_move_function(self, vec, face)
	end
end

function edge_fall_prevention.disable()
	if not is_enabled then return end
	is_enabled = false

	if update_connection then
		update_connection:Disconnect()
		update_connection = nil
	end

	if camera_connection then
		camera_connection:Disconnect()
		camera_connection = nil
	end

	local controls = get_controls()
	if controls and old_move_function then
		controls.moveFunction = old_move_function
		old_move_function = nil
	end

	last_floor_part = nil

	if overhang_part then
		update_character_cache()
		local standing_on_overhang = false

		if cached_root and cached_hum and cached_hum.Health > 0 then
			local drop_vec = Vector3.new(0, -cached_hum.HipHeight - 2, 0)
			local ray = workspace:Raycast(cached_root.Position, drop_vec, floor_ray_check)
			if ray and ray.Instance == overhang_part then
				standing_on_overhang = true
			end
		end

		-- The part should only be removed if the player isn't standing on it, so they can still stand on it without falling
		if standing_on_overhang then
			cleanup_connection = run_service.Heartbeat:Connect(function()
				update_character_cache()
				local still_on = false

				if cached_root and cached_hum and cached_hum.Health > 0 then
					local drop_vec = Vector3.new(0, -cached_hum.HipHeight - 2, 0)
					local ray = workspace:Raycast(cached_root.Position, drop_vec, floor_ray_check)
					if ray and ray.Instance == overhang_part then
						still_on = true
					end
				end

				-- They stepped back onto solid ground (or fell), safely destroy the part
				if not still_on then
					cleanup_connection:Disconnect()
					cleanup_connection = nil
					if overhang_part then
						overhang_part:Destroy()
						overhang_part = nil
					end
				end
			end)
		else
			overhang_part:Destroy()
			overhang_part = nil
		end
	end
end

return edge_fall_prevention
