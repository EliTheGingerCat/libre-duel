local UserInputService = game:GetService("UserInputService")

local attack_melee = require(script.Parent.Parent.combat.attack_melee)
local dissolve_cube = require(script.Parent.Parent.cube.dissolve_cube)
local keybinds = require(script.Parent.Parent.util.keybinds)
local place_cube = require(script.Parent.Parent.cube.place_cube)
local table_flip = require(script.Parent.Parent.util.table_flip)
local tool_state = require(script.Parent.tool_state)
local tools = require(script.Parent.tool_list)

type tool = tools.tool

local tool_selected: tool? = nil

local function set_tool(slot: number): ()
	tool_selected = tools[slot]
	tool_state.on_change:Fire(slot)
end

local tool_cube = table.find(tools, "cube")
set_tool(tool_cube or 1)

local key_to_slot = table_flip(keybinds.slot)

local function on_input_began(input: InputObject): ()
	local slot: number? = key_to_slot[input.KeyCode]
	if slot ~= nil then
		set_tool(slot)
	end

	if input.UserInputType == keybinds.tool_use then
		if tool_selected == "sword" then
			attack_melee()
		elseif tool_selected == "cube" then
			place_cube()
		elseif tool_selected == "dissolver" then
			dissolve_cube()
		end
	end
end

UserInputService.InputBegan:Connect(on_input_began)
