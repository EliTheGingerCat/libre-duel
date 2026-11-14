const ReplicatedStorage = game:GetService("ReplicatedStorage")
const ServerScriptService = game:GetService("ServerScriptService")

const create_cube = require(ReplicatedStorage.shared.cube.create_cube)
const cube_cache = require(ReplicatedStorage.shared.cube.cube_cache)
const CUBE_SIZE = require(ReplicatedStorage.shared.cube.CUBE_SIZE)
const match = require(ServerScriptService.match.match)
const snap_coordinate = require(ReplicatedStorage.shared.cube.snap_coordinate)
const tools = require(ReplicatedStorage.shared.tools.registry)
const tool_types = require(ReplicatedStorage.shared.tools.tool_types)

const TEAM1_CLAY = "red_clay"
const TEAM2_CLAY = "blue_clay"
const CENTER_CLAY = "white_clay"
-- Read from the template's `center_length` attribute, in cubes.
const DEFAULT_CENTER_LENGTH = 1

const function get_appearance(id: string): tool_types.cube_params
	const tool = tools.get(id)
	assert(tool and tool.behaviours.cube, `Tool "{id}" is not a cube.`)
	return tool.behaviours.cube
end

const function snap(position: Vector3): Vector3
	return Vector3.new(snap_coordinate(position.X), snap_coordinate(position.Y), snap_coordinate(position.Z))
end

-- Fills the template's volume with cubes: team 1's clay on the half nearest `team1_position`, team 2's on the other, and a strip of white clay in the middle.
const function generate_bridge(template: BasePart, team1_position: Vector3, this_match: match.match): ()
	-- Cubes are axis aligned, so only the world space extents of the template matter.
	const world_size = template.CFrame:VectorToWorldSpace(template.Size)
	const size = Vector3.new(math.abs(world_size.X), math.abs(world_size.Y), math.abs(world_size.Z))
	const counts =
		Vector3.new(math.round(size.X / CUBE_SIZE), math.round(size.Y / CUBE_SIZE), math.round(size.Z / CUBE_SIZE))
	const first = snap(template.Position - size / 2 + Vector3.one * (CUBE_SIZE / 2))

	const along_x = counts.X >= counts.Z
	const length = if along_x then counts.X else counts.Z
	const center_length = template:GetAttribute("center_length") or DEFAULT_CENTER_LENGTH
	assert(type(center_length) == "number", "Bridge `center_length` must be a number.")
	assert(
		(length - center_length) % 2 == 0,
		`A bridge {length} cubes long cannot have a centered strip {center_length} cubes long.`
	)

	const middle = (length - 1) / 2
	const team1_offset = (team1_position - template.Position):Dot(if along_x then Vector3.xAxis else Vector3.zAxis)
	const team1_side = math.sign(team1_offset)

	const team1_appearance = get_appearance(TEAM1_CLAY)
	const team2_appearance = get_appearance(TEAM2_CLAY)
	const center_appearance = get_appearance(CENTER_CLAY)

	for x = 0, counts.X - 1 do
		for y = 0, counts.Y - 1 do
			for z = 0, counts.Z - 1 do
				const distance = (if along_x then x else z) - middle
				const appearance = if math.abs(distance) < center_length / 2
					then center_appearance
					elseif math.sign(distance) == team1_side then team1_appearance
					else team2_appearance

				const cube = create_cube(appearance)
				cube.Position = first + Vector3.new(x, y, z) * CUBE_SIZE
				cube.Parent = workspace.runtime_instances.cubes
				cube_cache.track(cube)
				match.track_cube(this_match, cube)
			end
		end
	end

	template:Destroy()
end

return generate_bridge
