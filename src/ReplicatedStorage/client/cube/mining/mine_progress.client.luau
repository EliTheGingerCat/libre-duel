local ReplicatedStorage = game:GetService("ReplicatedStorage")

const TRANSPARENCY_MAXIMUM = require(script.Parent.TRANSPARENCY_MAXIMUM)
local set_cube_transparency = require(ReplicatedStorage.shared.cube.set_cube_transparency)
const zap_client_network = require(ReplicatedStorage.client.network.zap_client_network)

-- the cube is nil when it hasn't replicated to this client yet
const function on_fire(cube: Part?, time_fraction: number): ()
	if cube == nil then
		return
	end
	-- See `TRANSPARENCY_MAXIMUM.luau` for an explanation of this operation.
	local transparency_fraction = time_fraction * TRANSPARENCY_MAXIMUM
	set_cube_transparency(cube, transparency_fraction)
end

zap_client_network.mine_progress.set_callback(on_fire)
