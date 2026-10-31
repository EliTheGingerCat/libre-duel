const dissolve_cube = require(script.Parent.Parent.cube.dissolve_cube)
const tool_types = require(script.Parent.tool_types)

local function create(): tool_types.tool
	return {
		begin_use = dissolve_cube.start,
		cancel_use = dissolve_cube.stop,
		end_use = dissolve_cube.stop,
	}
end

return create
