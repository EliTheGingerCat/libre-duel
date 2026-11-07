const Players = game:GetService("Players")

const HORIZONTAL_AXES = Vector3.new(1, 0, 1)

const local_player = Players.LocalPlayer

-- horizontal speed of the local player, 0 while airborne or without a character
local function get_grounded_speed(): number
    const character = local_player.Character
    const humanoid = if character then character:FindFirstChildOfClass("Humanoid") else nil
    if humanoid == nil or humanoid.RootPart == nil or humanoid.FloorMaterial == Enum.Material.Air then
        return 0
    end
    return (humanoid.RootPart.AssemblyLinearVelocity * HORIZONTAL_AXES).Magnitude
end

return get_grounded_speed
