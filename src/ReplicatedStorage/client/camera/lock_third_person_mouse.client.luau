const Players = game:GetService("Players")
const RunService = game:GetService("RunService")
const UserInputService = game:GetService("UserInputService")
const Workspace = game:GetService("Workspace")

const camera_view_state = require(script.Parent.camera_view_state)
const cursor_state = require(script.Parent.Parent.ui.cursor_state)

const local_player = Players.LocalPlayer

-- first person is already locked by the engine, third person needs the lock and the facing done by hand
const function update_third_person_lock(): ()
	const character = local_player.Character
	const humanoid = if character then character:FindFirstChildOfClass("Humanoid") else nil
	const root = if character then character:FindFirstChild("HumanoidRootPart") else nil
	const locked = camera_view_state.third_person and not cursor_state.is_free()
	if humanoid == nil or root == nil or not root:IsA("BasePart") then
		return
	end
	if not locked then
		humanoid.AutoRotate = true
		return
	end
	UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
	humanoid.AutoRotate = false
	const look = Workspace.CurrentCamera.CFrame.LookVector
	const flat = Vector3.new(look.X, 0, look.Z)
	if flat.Magnitude > 0.001 then
		root.CFrame = CFrame.lookAt(root.Position, root.Position + flat)
	end
end

RunService:BindToRenderStep("third_person_lock", Enum.RenderPriority.Camera.Value - 1, update_third_person_lock)
