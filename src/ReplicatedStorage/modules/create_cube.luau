local cube_size = require(script.Parent.cube_size)

local id = 0

local function create_cube(): Part
	id += 1
	local cube = Instance.new("Part")
	cube.Anchored = true
	cube:AddTag("cube")
	cube.Material = Enum.Material.Brick
	cube.Name = `Cube #{id}`
	cube.Size = Vector3.one * cube_size
	return cube
end

return create_cube
