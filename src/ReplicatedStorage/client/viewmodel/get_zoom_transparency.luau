const Players = game:GetService("Players")

const local_player = Players.LocalPlayer

-- the default camera scripts fade the character out as you zoom in by setting this on its parts,
-- so the inverse fades the viewmodel in at the same rate
const function get_zoom_transparency(): number
    const character = local_player.Character
    const head = if character then character:FindFirstChild("Head") else nil
    if head == nil or not head:IsA("BasePart") then
        return 0
    end
    return 1 - head.LocalTransparencyModifier
end

return get_zoom_transparency
