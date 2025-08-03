local UserInputService = game:GetService("UserInputService")

local attack_melee = require(script.Parent.modules.attack_melee)
local keybinds = require(script.Parent.modules.keybinds)
local place_voxel = require(script.Parent.modules.place_voxel)

type tool = "sword" | "voxel"

local tool: tool = "voxel"

local function switch_tool(): ()
	if tool == "sword" then
		tool = "voxel"
	else
		tool = "sword"
	end
end

local function on_input_began(input: InputObject): ()
	if input.KeyCode == keybinds.tool_switch then
		switch_tool()
	elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
		if tool == "sword" then
			attack_melee()
		else
			place_voxel()
		end
	end
end

UserInputService.InputBegan:Connect(on_input_began)
