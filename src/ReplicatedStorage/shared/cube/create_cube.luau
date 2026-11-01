const ReplicatedStorage = game:GetService("ReplicatedStorage")

const CUBE_SIZE = require(script.Parent.CUBE_SIZE)
const registry = require(ReplicatedStorage.shared.tools.registry)

local id = 0

local function create_cube(appearance: registry.appearance): Part
	id += 1
	local cube = Instance.new("Part")
	cube.Anchored = true
	cube:AddTag("cube")
	cube.Name = `Cube #{id}`
	cube.Size = Vector3.one * CUBE_SIZE
	if appearance.colour ~= nil then
		cube.Color = appearance.colour
	end
	if appearance.material ~= nil then
		cube.Material = appearance.material
	end
	if appearance.shape ~= nil then
		cube.Shape = appearance.shape
	end
	return cube
end

return create_cube
