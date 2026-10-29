const CUBE_SIZE = require(script.Parent.CUBE_SIZE)

local id = 0

local function create_cube(): Part
	id += 1
	local cube = Instance.new("Part")
	cube.Anchored = true
	cube:AddTag("cube")
	cube.Material = Enum.Material.Brick
	cube.Name = `Cube #{id}`
	cube.Size = Vector3.one * CUBE_SIZE
	return cube
end

return create_cube
