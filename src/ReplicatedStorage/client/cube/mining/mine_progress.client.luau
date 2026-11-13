local ReplicatedStorage = game:GetService("ReplicatedStorage")

const TRANSPARENCY_MAXIMUM = require(script.Parent.TRANSPARENCY_MAXIMUM)
local set_cube_transparency = require(ReplicatedStorage.shared.cube.set_cube_transparency)

local function on_fire(cube: Part, time_fraction: number): ()
	-- See `TRANSPARENCY_MAXIMUM.luau` for an explanation of this operation.
	local transparency_fraction = time_fraction * TRANSPARENCY_MAXIMUM
	set_cube_transparency(cube, transparency_fraction)
end

ReplicatedStorage.remotes.mine_progress.OnClientEvent:Connect(on_fire)
