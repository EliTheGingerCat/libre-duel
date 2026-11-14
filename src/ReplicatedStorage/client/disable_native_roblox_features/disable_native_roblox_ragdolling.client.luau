const Players = game:GetService("Players")
const ReplicatedStorage = game:GetService("ReplicatedStorage")

const registry = require(ReplicatedStorage.shared.entity.registry)

const DISABLED_STATES: { Enum.HumanoidStateType } = {
	Enum.HumanoidStateType.FallingDown,
	Enum.HumanoidStateType.Ragdoll,
}

const local_player = Players.LocalPlayer

const function on_character_added(character: Model, entity: registry.entity): ()
	if entity ~= local_player then
		return
	end
	const humanoid = character:WaitForChild("Humanoid", 10)
	if humanoid == nil or not humanoid:IsA("Humanoid") then
		return
	end
	for _, state in DISABLED_STATES do
		humanoid:SetStateEnabled(state, false)
	end
end

registry.character_added:Connect(on_character_added)
