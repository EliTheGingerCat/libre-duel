const Players = game:GetService("Players")

const invoke_hurtcam = require(script.Parent.invoke_hurtcam)

local character = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

local old_health: number = humanoid.Health

humanoid.HealthChanged:Connect(function(new_health)
    if new_health < old_health then
        invoke_hurtcam(10, .7)
    end
        old_health = new_health
end)
