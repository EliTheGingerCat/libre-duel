local replicated_storage = game:GetService("ReplicatedStorage")
local run_service = game:GetService("RunService")

local get_fps = require(replicated_storage.client.util.get_fps)

local function mount_fps(label: TextLabel)
	local icon = label:FindFirstChild("Icon")
	assert(icon and icon:IsA("ImageLabel"))
	icon.Image = "rbxassetid://113292629307398"

	local function update(): ()
		local text = `{get_fps()} FPS`
		if label.Text ~= text then
			label.Text = text
		end
	end

	update()
	local connection = run_service.RenderStepped:Connect(update)
	local function disconnect(): ()
		connection:Disconnect()
	end
	return disconnect
end

return mount_fps
