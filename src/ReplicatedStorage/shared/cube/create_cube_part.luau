const ReplicatedStorage = game:GetService("ReplicatedStorage")

const tool_types = require(ReplicatedStorage.shared.tools.tool_types)

-- only the look of a cube, without what makes it a placed block
const function create_cube_part(appearance: tool_types.cube_params, size: number): Part
	const cube = Instance.new("Part")
	cube.Size = Vector3.one * size
	if appearance.colour ~= nil then
		cube.Color = appearance.colour
	end
	if appearance.material ~= nil then
		cube.Material = appearance.material
	end
	if appearance.shape ~= nil then
		cube.Shape = appearance.shape
	end
	if appearance.texture_id ~= nil then
		for _, face in Enum.NormalId:GetEnumItems() do
			const texture = Instance.new("Texture")
			texture.Face = face
			texture.StudsPerTileU = size
			texture.StudsPerTileV = size
			texture.Texture = appearance.texture_id
			texture.Parent = cube
		end
	end
	return cube
end

return create_cube_part
