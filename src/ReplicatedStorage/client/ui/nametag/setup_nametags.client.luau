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

	local function render_health(health: number): ()
		tree:render(ReactRoblox.createPortal(
			create_element(nametag, {
				adornee = head,
				name = registry.get_name(entity),
				extra_text = `♥ {math.round(health)}`,
			}),
			head
		))
	end

	const health_connection = humanoid.HealthChanged:Connect(render_health)
	local destroying_connection: RBXScriptConnection? = nil
	local function cleanup(): ()
		health_connection:Disconnect()
		if destroying_connection then
			destroying_connection:Disconnect()
		end
		tree:unmount()
		container:Destroy()
		cleanups[entity] = nil
	end
	cleanups[entity] = cleanup
	destroying_connection = head.Destroying:Once(cleanup)
	render_health(humanoid.Health)
end

registry.character_added:Connect(on_character_added)
registry.removed:Connect(on_entity_removed)
for _, entity in registry.get_all() do
	const character = registry.get_character(entity)
	if character then
		task.spawn(on_character_added, character, entity)
	end
end
