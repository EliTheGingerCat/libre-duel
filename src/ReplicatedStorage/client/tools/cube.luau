const place_cube = require(script.Parent.Parent.cube.place_cube)
const tool_types = require(script.Parent.tool_types)

local function begin_use(): ()
	task.spawn(place_cube)
end

local function create(): tool_types.tool
	return {
		begin_use = begin_use,
	}
end

return create
