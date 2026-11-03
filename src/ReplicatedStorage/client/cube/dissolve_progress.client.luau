local ReplicatedStorage = game:GetService("ReplicatedStorage")

const TRANSPARENCY_MAXIMUM = require(script.Parent.TRANSPARENCY_MAXIMUM)

local function on_fire(cube: Part, time_fraction: number): ()
	-- See `TRANSPARENCY_MAXIMUM.luau` for an explanation of this operation.
	local transparency_fraction = time_fraction * TRANSPARENCY_MAXIMUM
	cube.Transparency = transparency_fraction
end

ReplicatedStorage.remotes.dissolve_progress.OnClientEvent:Connect(on_fire)
