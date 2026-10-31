local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local attack_melee = require(ReplicatedStorage.client.combat.attack_melee)
local dissolve_cube = require(ReplicatedStorage.client.cube.dissolve_cube)
local eat_cake = require(ReplicatedStorage.client.cake.eat_cake)
local editor_state = require(ReplicatedStorage.client.ui.hud.editor_state)
const KEYBINDS = require(ReplicatedStorage.client.util.KEYBINDS)
local place_cube = require(ReplicatedStorage.client.cube.place_cube)
local pull_bow = require(ReplicatedStorage.client.bow.pull_bow)
local table_flip = require(ReplicatedStorage.client.util.table_flip)
const TOOLS = require(ReplicatedStorage.client.tools.TOOL_LIST)
local tool_state = require(ReplicatedStorage.client.tools.tool_state)

type tool = TOOLS.tool

local tool_selected: tool? = nil

local function set_tool(slot: number): ()
	tool_selected = TOOLS[slot]
	tool_state.current = slot
	tool_state.on_change:Fire(slot)
end

local tool_cube = table.find(TOOLS, "cube")
set_tool(tool_cube or 1)

local key_to_slot = table_flip(KEYBINDS.slot)

local function on_input_began(input: InputObject, game_processed: boolean): ()
	if game_processed or editor_state.enabled then
		return
	end

	local slot: number? = key_to_slot[input.KeyCode]
	if slot ~= nil then
		set_tool(slot)
	end

	if input.UserInputType == KEYBINDS.tool_use then
		if tool_selected == "sword" then
			attack_melee()
		elseif tool_selected == "cube" then
			place_cube()
		elseif tool_selected == "dissolver" then
			dissolve_cube()
		elseif tool_selected == "bow" then
			pull_bow()
		elseif tool_selected == "cake" then
			eat_cake()
		end
	end
end

UserInputService.InputBegan:Connect(on_input_began)
