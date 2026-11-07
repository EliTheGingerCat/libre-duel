local function create_viewmodel_part(): Part
    const part = Instance.new("Part")
    part.Size = Vector3.new(0.1, 0.1, 0.1) --making it so smol so that it doesn't clip into walls
    -- unanchored, it falls out of the world and gets destroyed whenever nothing is positioning it
    part.Anchored = true
    part.CanCollide = false
    part.CanTouch = false
    part.CanQuery = false
    -- Im doing this so the viewmodel wont be shown if theres no mesh to show yet
    part.Transparency = 1

    const specialmesh = Instance.new("SpecialMesh")
    specialmesh.Parent = part
    specialmesh.MeshType = Enum.MeshType.FileMesh
    specialmesh.Scale = Vector3.new(0.1, 0.1, 0.1)

    return part
end

return create_viewmodel_part
