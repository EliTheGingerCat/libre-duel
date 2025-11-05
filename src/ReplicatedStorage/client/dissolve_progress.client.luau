local ReplicatedStorage = game:GetService("ReplicatedStorage")

local function on_fire(cube: Part, transparency: number): ()
	cube.Transparency = transparency
end

ReplicatedStorage.remotes.dissolve_progress.OnClientEvent:Connect(on_fire)
