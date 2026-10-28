local players = game:GetService("Players")
local run_service = game:GetService("RunService")

local local_player = players.LocalPlayer

type part_pair = {
	source: BasePart,
	copy: BasePart,
}

local function collect_parts(source: Instance, copy: Instance, parts: { part_pair }): ()
	if source:IsA("BasePart") and copy:IsA("BasePart") then
		copy.Anchored = true
		copy.CanCollide = false
		copy.LocalTransparencyModifier = 0
		table.insert(parts, { source = source, copy = copy })
	end
	local remaining = copy:GetChildren()
	for _, source_child in source:GetChildren() do
		for index, copy_child in remaining do
			if copy_child.Name == source_child.Name and copy_child.ClassName == source_child.ClassName then
				collect_parts(source_child, copy_child, parts)
				table.remove(remaining, index)
				break
			end
		end
	end
end

local function mount_paperdoll(viewport: ViewportFrame)
	local world = Instance.new("WorldModel")
	world.Parent = viewport
	local camera = Instance.new("Camera")
	camera.FieldOfView = 35
	camera.Parent = viewport
	viewport.CurrentCamera = camera

	local character: Model? = nil
	local copy: Model? = nil
	local parts: { part_pair } = {}
	local character_connections: { RBXScriptConnection } = {}
	local rebuild_pending = false
	local active = true

	local function clear_copy(): ()
		table.clear(parts)
		if copy then
			copy:Destroy()
			copy = nil
		end
	end

	local function update_pose(): ()
		local source = character
		if not source then
			return
		end
		local root = source:FindFirstChild("HumanoidRootPart")
		if not root or not root:IsA("BasePart") then
			return
		end
		for _, pair in parts do
			if pair.source:IsDescendantOf(source) then
				pair.copy.CFrame = root.CFrame:ToObjectSpace(pair.source.CFrame)
			end
		end
	end

	local function rebuild(): ()
		rebuild_pending = false
		if not active then
			return
		end
		clear_copy()
		local source = character
		if not source or not source:FindFirstChild("HumanoidRootPart") then
			return
		end

		local archivable = source.Archivable
		source.Archivable = true
		local new_copy = source:Clone()
		source.Archivable = archivable
		collect_parts(source, new_copy, parts)
		for _, descendant in new_copy:GetDescendants() do
			if
				descendant:IsA("LuaSourceContainer")
				or descendant:IsA("JointInstance")
				or descendant:IsA("Constraint")
				or descendant:IsA("Sound")
				or descendant:IsA("Highlight")
				or descendant:IsA("ParticleEmitter")
				or descendant:IsA("Trail")
				or descendant:IsA("Beam")
			then
				descendant:Destroy()
			end
		end
		copy = new_copy
		update_pose()
		new_copy.Parent = world

		local bounds, size = new_copy:GetBoundingBox()
		local centre = bounds.Position
		local half_fov = math.rad(camera.FieldOfView / 2)
		local aspect = viewport.Size.X.Offset / viewport.Size.Y.Offset
		local distance = math.max(size.Y, size.X / aspect) / (2 * math.tan(half_fov)) + size.Z / 2
		camera.CFrame = CFrame.new(centre + Vector3.new(0, 0, -distance * 1.1)) * CFrame.Angles(0, math.pi, 0)
	end

	local function schedule_rebuild(): ()
		if not rebuild_pending then
			rebuild_pending = true
			task.defer(rebuild)
		end
	end

	local function on_descendant_changed(descendant: Instance): ()
		if descendant:IsA("BasePart") or descendant:IsA("Clothing") or descendant:IsA("CharacterMesh") then
			schedule_rebuild()
		end
	end

	local function detach_character(): ()
		for _, connection in character_connections do
			connection:Disconnect()
		end
		table.clear(character_connections)
		character = nil
		clear_copy()
	end

	local function on_character_added(new_character: Model): ()
		detach_character()
		character = new_character
		table.insert(character_connections, new_character.DescendantAdded:Connect(on_descendant_changed))
		table.insert(character_connections, new_character.DescendantRemoving:Connect(on_descendant_changed))
		schedule_rebuild()
	end

	local added_connection = local_player.CharacterAdded:Connect(on_character_added)
	local removing_connection = local_player.CharacterRemoving:Connect(detach_character)
	local appearance_connection = local_player.CharacterAppearanceLoaded:Connect(schedule_rebuild)
	local render_connection = run_service.RenderStepped:Connect(update_pose)
	if local_player.Character then
		on_character_added(local_player.Character)
	end

	local function disconnect(): ()
		active = false
		detach_character()
		added_connection:Disconnect()
		removing_connection:Disconnect()
		appearance_connection:Disconnect()
		render_connection:Disconnect()
		camera:Destroy()
		world:Destroy()
	end

	return disconnect
end

return mount_paperdoll
