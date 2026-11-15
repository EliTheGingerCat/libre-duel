const ReplicatedStorage = game:GetService("ReplicatedStorage")
const Workspace = game:GetService("Workspace")

const registry = require(ReplicatedStorage.shared.entity.registry)

const line_of_sight_parameters = RaycastParams.new()
line_of_sight_parameters.FilterType = Enum.RaycastFilterType.Exclude

-- characters never block, only the world does
const function is_line_of_sight_clear(from: Vector3, to: Vector3): boolean
	const characters: { Instance } = {}
	for _, entity in registry.get_all() do
		const character = registry.get_character(entity)
		if character then
			table.insert(characters, character)
		end
	end
	line_of_sight_parameters.FilterDescendantsInstances = characters
	return Workspace:Raycast(from, to - from, line_of_sight_parameters) == nil
end

return is_line_of_sight_clear
