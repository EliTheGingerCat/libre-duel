local ReplicatedStorage = game:GetService("ReplicatedStorage")

local transparency_maximum = require(script.Parent.modules.cube.transparency_maximum)

local function on_fire(cube: Part, time_fraction: number): ()
	-- See `transparency_maximum.luau` for an explanation of this operation.
	local transparency_fraction = time_fraction * transparency_maximum
	cube.Transparency = transparency_fraction
end

ReplicatedStorage.remotes.dissolve_progress.OnClientEvent:Connect(on_fire)
