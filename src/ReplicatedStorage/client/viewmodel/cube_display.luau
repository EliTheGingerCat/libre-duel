const ReplicatedStorage = game:GetService("ReplicatedStorage")
const Workspace = game:GetService("Workspace")

const tool_types = require(ReplicatedStorage.shared.tools.tool_types)
const VIEWMODEL_CONSTANTS = require(script.Parent.VIEWMODEL_CONSTANTS)

const SIZE = VIEWMODEL_CONSTANTS.cube_size

local part: Part? = nil
local textures: { Texture } = {}

const function hide(): ()
	if part ~= nil then
		part:Destroy()
	end
	part = nil
	table.clear(textures)
end

const function add_textures(cube: Part, texture_id: string): ()
	for _, face in Enum.NormalId:GetEnumItems() do
		const texture = Instance.new("Texture")
		texture.Face = face
		texture.StudsPerTileU = SIZE
		texture.StudsPerTileV = SIZE
		texture.Texture = texture_id
		texture.Parent = cube
		table.insert(textures, texture)
	end
end

-- not using create_cube because this must not get the "cube" tag, and textures need to fit this size
const function show(tool: tool_types.tool): ()
	hide()

	const appearance: tool_types.cube_params = tool.behaviours.cube or {}
	const cube = Instance.new("Part")
	cube.Size = Vector3.one * SIZE
	cube.Anchored = true
	cube.CanCollide = false
	cube.CanQuery = false
	cube.CanTouch = false
	cube.CastShadow = false
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
		add_textures(cube, appearance.texture_id)
	end
	cube.Parent = Workspace.CurrentCamera
	part = cube
end

const function get_part(): BasePart?
	return part
end

-- textures don't inherit this from their part
const function set_transparency(transparency: number): ()
	if part == nil then
		return
	end
	part.LocalTransparencyModifier = transparency
	for _, texture in textures do
		texture.LocalTransparencyModifier = transparency
	end
end

return {
	show = show,
	hide = hide,
	get_part = get_part,
	set_transparency = set_transparency,
}
