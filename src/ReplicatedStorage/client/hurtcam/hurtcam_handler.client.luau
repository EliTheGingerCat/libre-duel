const Players = game:GetService("Players")
const ReplicatedStorage = game:GetService("ReplicatedStorage")

const registry = require(ReplicatedStorage.shared.entity.registry)
const invoke_hurtcam = require(script.Parent.invoke_hurtcam)

const HURTCAM_STRENGTH = 10
const HURTCAM_DURATION_S = 0.7

const local_player = Players.LocalPlayer

const function on_character_added(character: Model, entity: registry.entity): ()
	if entity ~= local_player then
		return
	end
	const humanoid = character:WaitForChild("Humanoid", 10)
	if humanoid == nil or not humanoid:IsA("Humanoid") then
		return
	end

	local old_health = humanoid.Health

	const function on_health_changed(new_health: number): ()
		if new_health < old_health then
			invoke_hurtcam(HURTCAM_STRENGTH, HURTCAM_DURATION_S)
		end
		old_health = new_health
	end

	humanoid.HealthChanged:Connect(on_health_changed)
end

registry.character_added:Connect(on_character_added)
-- the registry fires for existing characters when it loads, which can be before this connects
if local_player.Character then
	on_character_added(local_player.Character, local_player)
end
