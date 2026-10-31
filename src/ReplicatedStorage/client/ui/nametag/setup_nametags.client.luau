const ReplicatedStorage = game:GetService("ReplicatedStorage")

const nametag = require(script.Parent.Parent.visuals.nametag)
const React = require(ReplicatedStorage.Packages.react)
const ReactRoblox = require(ReplicatedStorage.Packages["react-roblox"])
const registry = require(ReplicatedStorage.shared.entity.registry)

const create_element = React.createElement
const cleanups: { [registry.entity]: () -> () } = {}

local function on_entity_removed(entity: registry.entity): ()
	const cleanup = cleanups[entity]
	if cleanup then
		cleanup()
	end
end

local function on_character_added(character: Model, entity: registry.entity): ()
	const head = character:WaitForChild("Head", 10)
	const humanoid = character:WaitForChild("Humanoid", 10)
	if head == nil or humanoid == nil or not humanoid:IsA("Humanoid") then
		return
	end
	if registry.get_character(entity) ~= character then
		return
	end
	on_entity_removed(entity)
	const container = Instance.new("Folder")
	const tree = ReactRoblox.createRoot(container)

	local function render(): ()
		local team = registry.get_team(entity)
		tree:render(ReactRoblox.createPortal(
			create_element(nametag, {
				adornee = head,
				name = if type(entity) == "string" then registry.get_name(entity) else entity.DisplayName,
				colour = if team then team.TeamColor.Color else Color3.fromRGB(255, 255, 255),
				extra_text = `♥ {math.round(humanoid.Health)}`,
			}),
			head
		))
	end

	local team: Team? = nil
	local team_connection: RBXScriptConnection? = nil
	local function on_identity_changed(): ()
		local current_team = registry.get_team(entity)
		if team ~= current_team then
			if team_connection then
				team_connection:Disconnect()
			end
			team = current_team
			team_connection = if team then team:GetPropertyChangedSignal("TeamColor"):Connect(render) else nil
		end
		render()
	end
	const health_connection = humanoid.HealthChanged:Connect(render)
	const identity_connection = registry.changed:Connect(on_identity_changed)
	local display_name_connection: RBXScriptConnection? = nil
	if type(entity) ~= "string" then
		display_name_connection = entity:GetPropertyChangedSignal("DisplayName"):Connect(render)
	end
	local destroying_connection: RBXScriptConnection? = nil
	local active = true
	local function cleanup(): ()
		if not active then
			return
		end
		active = false
		health_connection:Disconnect()
		identity_connection:Disconnect()
		if display_name_connection then
			display_name_connection:Disconnect()
		end
		if team_connection then
			team_connection:Disconnect()
		end
		if destroying_connection then
			destroying_connection:Disconnect()
		end
		tree:unmount()
		container:Destroy()
		cleanups[entity] = nil
	end
	cleanups[entity] = cleanup
	destroying_connection = head.Destroying:Once(cleanup)
	on_identity_changed()
end

registry.character_added:Connect(on_character_added)
registry.removed:Connect(on_entity_removed)
for _, entity in registry.get_all() do
	const character = registry.get_character(entity)
	if character then
		task.spawn(on_character_added, character, entity)
	end
end
