local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local local_camera = Workspace.CurrentCamera

local function on_event(orientation_frame: CFrame): ()
	local position_vector = local_camera.CFrame.Position
	local position_frame = CFrame.new(position_vector)
	local full_frame = position_frame * orientation_frame
	local_camera.CFrame = full_frame
end

ReplicatedStorage.remotes.camera_look.OnClientEvent:Connect(on_event)
