const ReplicatedStorage = game:GetService("ReplicatedStorage")
const Workspace = game:GetService("Workspace")

const ITEM_SPRITE_FRAMES = require(script.Parent.ITEM_SPRITE_FRAMES)
const create_viewmodel_part = require(script.Parent.create_viewmodel_part)
const tool_types = require(ReplicatedStorage.shared.tools.tool_types)

const part = create_viewmodel_part()
const specialmesh = part:FindFirstChildOfClass("SpecialMesh") :: SpecialMesh
part.Parent = Workspace.CurrentCamera

local sprite_frame: ITEM_SPRITE_FRAMES.sprite_frame = ITEM_SPRITE_FRAMES.default

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
	sprite_frame = ITEM_SPRITE_FRAMES.frames[tool.id] or ITEM_SPRITE_FRAMES.default
	set_mesh(tool.mesh)
	set_texture(tool.image)
	part.Transparency = 0
	part.Parent = Workspace.CurrentCamera
end

const function set_pose(cframe: CFrame, studs_per_unit: number): ()
	part.CFrame = cframe * CFrame.Angles(0, 0, math.rad(sprite_frame.rotation))
	specialmesh.Scale = Vector3.one * (studs_per_unit * sprite_frame.scale)
end

const function set_transparency(transparency: number): ()
	part.LocalTransparencyModifier = transparency
end

return {
	show = show,
	hide = hide,
	set_pose = set_pose,
	set_transparency = set_transparency,
	set_mesh = set_mesh,
	set_texture = set_texture,
}
