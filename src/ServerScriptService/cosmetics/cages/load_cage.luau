const ReplicatedStorage = game:GetService("ReplicatedStorage")
const ServerStorage = game:GetService("ServerStorage")

const cage_data = require(ReplicatedStorage.shared.cosmetics.cage_data)

export type loaded_cage = {
	root: Instance,
	spawn: BasePart,
	bounds: BasePart,
}

const function hide_marker_part(part: BasePart): ()
	part.Transparency = 1
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
end

-- clones the cage so that its spawn lands exactly on `spawn_frame`, the cage is left unparented
const function load_cage(cage_name: string, spawn_frame: CFrame): loaded_cage
	const cage_template = ServerStorage.cosmetics.cages:FindFirstChild(cage_name)
	assert(cage_template, `No cage named "{cage_name}"`)

	const cage_root = cage_template:Clone()
	const info_module = cage_root:FindFirstChild("CAGE_INFO")
	assert(info_module and info_module:IsA("ModuleScript"), `Cage "{cage_name}" is missing CAGE_INFO`)
	const load_info: (ModuleScript) -> cage_data.cage_data = require
	const info = load_info(info_module)

	const cage_offset = spawn_frame * info.SPAWN.CFrame:Inverse()
	for _, descendant in cage_root:GetDescendants() do
		if descendant:IsA("BasePart") then
			descendant.CFrame = cage_offset * descendant.CFrame
		end
	end

	hide_marker_part(info.SPAWN)
	hide_marker_part(info.BOUNDS)

	return {
		root = cage_root,
		spawn = info.SPAWN,
		bounds = info.BOUNDS,
	}
end

return load_cage
