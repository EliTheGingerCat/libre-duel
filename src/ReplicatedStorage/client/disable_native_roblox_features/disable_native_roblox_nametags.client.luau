const ReplicatedStorage = game:GetService("ReplicatedStorage")

const registry = require(ReplicatedStorage.shared.entity.registry)

const function hide_native_nametag(character: Model, _entity: registry.entity): ()
	const humanoid = character:WaitForChild("Humanoid", 10)
	if humanoid == nil or not humanoid:IsA("Humanoid") then
		return
	end
	humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
end

registry.character_added:Connect(hide_native_nametag)
-- the registry fires for existing characters when it loads, which can be before this connects
for _, entity in registry.get_all() do
	const character = registry.get_character(entity)
	if character then
		task.spawn(hide_native_nametag, character, entity)
	end
end
