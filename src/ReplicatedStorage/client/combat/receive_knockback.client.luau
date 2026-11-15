const Players = game:GetService("Players")
const ReplicatedStorage = game:GetService("ReplicatedStorage")

const apply_knockback = require(ReplicatedStorage.shared.combat.apply_knockback)

const local_player = Players.LocalPlayer

const function on_knockback(vector: Vector3, strength_x: number, strength_y: number): ()
	const character = local_player.Character
	const root = if character then character:FindFirstChild("HumanoidRootPart") else nil
	if root == nil or not root:IsA("BasePart") then
		return
	end
	apply_knockback(vector, root, strength_x, strength_y)
end

ReplicatedStorage.remotes.knockback.OnClientEvent:Connect(on_knockback)
