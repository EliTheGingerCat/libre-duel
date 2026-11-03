local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local function on_input_began(input: InputObject): ()
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		ReplicatedStorage.remotes.mouse_click:FireServer()
	end
end

UserInputService.InputBegan:Connect(on_input_began)
