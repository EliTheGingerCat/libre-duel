const ReplicatedStorage = game:GetService("ReplicatedStorage")

const create_cube_part = require(ReplicatedStorage.shared.cube.create_cube_part)
const tool_types = require(ReplicatedStorage.shared.tools.tool_types)
const THIRD_PERSON_TOOL_CONSTANTS = require(script.Parent.THIRD_PERSON_TOOL_CONSTANTS)

const function create_mesh_part(mesh_id: string, texture_id: string): Part
    const part = Instance.new("Part")
    part.Size = Vector3.one

    const specialmesh = Instance.new("SpecialMesh")
    specialmesh.MeshType = Enum.MeshType.FileMesh
    specialmesh.MeshId = mesh_id
    specialmesh.TextureId = texture_id
    specialmesh.Scale = Vector3.one * THIRD_PERSON_TOOL_CONSTANTS.mesh_scale
    specialmesh.Parent = part

    return part
end

-- nil for tools that have nothing to show, the same ones the viewmodel leaves empty
const function create_held_part(tool: tool_types.tool): Part?
    const cube = tool.behaviours.cube
    const mesh_id = tool.mesh

    local part: Part
    if cube ~= nil then
        part = create_cube_part(cube, THIRD_PERSON_TOOL_CONSTANTS.cube_size)
    elseif mesh_id ~= nil then
        part = create_mesh_part(mesh_id, tool.image)
    else
        return nil
    end

    part.Name = "held_tool"
    part.Massless = true
    part.CanCollide = false
    part.CanTouch = false
    -- otherwise it would block clicks, cube placement and arrows
    part.CanQuery = false
    return part
end

return create_held_part
