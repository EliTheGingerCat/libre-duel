const ReplicatedStorage = game:GetService("ReplicatedStorage")
const ServerScriptService = game:GetService("ServerScriptService")
const ServerStorage = game:GetService("ServerStorage")

const debug_print = require(ServerScriptService.util.debug_print)
const registry = require(ReplicatedStorage.shared.entity.registry)

const hitbox = ServerStorage.hitbox
const cube_hitbox = ServerStorage.cube_hitbox

local function attach_part(template: BasePart, root: BasePart): ()
	if root:FindFirstChild(template.Name) then
		return
	end
	const clone = template:Clone()
	const weld = clone:FindFirstChildOfClass("Weld")
	if weld == nil then
		clone:Destroy()
		return
	end
	weld.Part0 = clone
	weld.Part1 = root
	clone.Parent = root
end

local function on_character_added(character: Model): ()
	const root = character:WaitForChild("HumanoidRootPart", 10)
	if root == nil or not root:IsA("BasePart") then
		debug_print("Humanoid root part is missing.")
		return
	end

	attach_part(hitbox, root)
	attach_part(cube_hitbox, root)
end

registry.character_added:Connect(on_character_added)
for _, entity in registry.get_all() do
	const character = registry.get_character(entity)
	if character then
		task.spawn(on_character_added, character)
	end
end
