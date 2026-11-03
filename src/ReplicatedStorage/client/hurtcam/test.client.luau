const Players = game:GetService("Players")

const invoke_hurtcam = require(script.Parent.invoke_hurtcam)

const character = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()
const humanoid = character:WaitForChild("Humanoid") :: Humanoid

local old_health: number = humanoid.Health

local function on_health_changed(new_health: number): ()
	if new_health < old_health then
		invoke_hurtcam(10, 0.7)
	end
	old_health = new_health
end

humanoid.HealthChanged:Connect(on_health_changed)
