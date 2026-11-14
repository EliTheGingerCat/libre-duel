const ReplicatedStorage = game:GetService("ReplicatedStorage")
const Workspace = game:GetService("Workspace")

const create_viewmodel_part = require(script.Parent.create_viewmodel_part)
const tool_types = require(ReplicatedStorage.shared.tools.tool_types)

const part = create_viewmodel_part()
const specialmesh = part:FindFirstChildOfClass("SpecialMesh") :: SpecialMesh
part.Parent = Workspace.CurrentCamera

const function hide(): ()
	part.Transparency = 1
end

const function set_mesh(mesh: string): ()
	specialmesh.MeshId = mesh
end

const function set_texture(texture: string): ()
	specialmesh.TextureId = texture
end

const function show(tool: tool_types.tool): ()
	if tool.mesh == nil then
		hide()
		return
	end
	set_mesh(tool.mesh)
	set_texture(tool.image)
	part.Transparency = 0
	part.Parent = Workspace.CurrentCamera
end

const function get_part(): BasePart?
	return part
end

const function set_transparency(transparency: number): ()
	part.LocalTransparencyModifier = transparency
end

return {
	show = show,
	hide = hide,
	get_part = get_part,
	set_transparency = set_transparency,
	set_mesh = set_mesh,
	set_texture = set_texture,
}
