const SPAWN_PIVOT_OFFSET = require(script.Parent.SPAWN_PIVOT_OFFSET)

const SLAB_THICKNESS = 1

-- roblox places spawning characters on top of a SpawnLocation, so the slab sits just below `pivot_frame`
const function create_spawn_location(pivot_frame: CFrame, footprint: Vector3, team_colour: BrickColor): SpawnLocation
	const spawn_location = Instance.new("SpawnLocation")
	spawn_location.Size = Vector3.new(footprint.X, SLAB_THICKNESS, footprint.Z)
	spawn_location.CFrame = pivot_frame * SPAWN_PIVOT_OFFSET:Inverse()
	spawn_location.Anchored = true
	spawn_location.Transparency = 1
	-- roblox ignores a RespawnLocation it can't collide with or query
	spawn_location.CanTouch = false
	spawn_location.Neutral = false
	spawn_location.TeamColor = team_colour
	spawn_location.AllowTeamChangeOnTouch = false
	spawn_location.Duration = 0
	return spawn_location
end

return create_spawn_location
