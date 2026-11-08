const ReplicatedStorage = game:GetService("ReplicatedStorage")

const CUBE_SIZE = require(script.Parent.CUBE_SIZE)
const create_cube_part = require(script.Parent.create_cube_part)
const tool_types = require(ReplicatedStorage.shared.tools.tool_types)

local id = 0

local function create_cube(appearance: tool_types.cube_params): Part
	id += 1
	local cube = create_cube_part(appearance, CUBE_SIZE)
	cube.Anchored = true
	cube:AddTag("cube")
	cube.Name = `Cube #{id}`
	return cube
end

return create_cube
