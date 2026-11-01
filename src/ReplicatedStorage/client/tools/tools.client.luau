local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local attack_melee = require(script.Parent.sword.attack_melee)
local dissolve_cube = require(script.Parent.dissolver.dissolve_cube)
local eat_cake = require(script.Parent.cake.eat_cake)
local editor_state = require(ReplicatedStorage.client.ui.hud.editor_state)
local get_slot_tool = require(script.Parent.get_slot_tool)
const KEYBINDS = require(ReplicatedStorage.client.util.KEYBINDS)
local mode_selector_state = require(ReplicatedStorage.client.ui.matchmaking.mode_selector_state)
local open_mode_selector = require(script.Parent.mode_selector.open_mode_selector)
local place_cube = require(script.Parent.cube.place_cube)
local pull_bow = require(script.Parent.bow.pull_bow)
local registry = require(ReplicatedStorage.shared.tools.registry)
local table_flip = require(ReplicatedStorage.client.util.table_flip)
const TOOLS = require(script.Parent.TOOL_LIST)
local tool_state = require(script.Parent.tool_state)

-- Variants share their base tool's behaviour, so each handler receives the selected tool to read its appearance.
const HANDLERS: { [registry.behaviour]: (tool: registry.tool) -> () } = {
	bow = pull_bow,
	cake = eat_cake,
	cube = place_cube,
	dissolver = dissolve_cube,
	mode_selector = open_mode_selector,
	sword = attack_melee,
}

local tool_selected: registry.tool? = nil

local function set_tool(slot: number): ()
	tool_selected = get_slot_tool(slot)
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

	if mode_selector_state.enabled then
		return
	end

	if input.UserInputType == KEYBINDS.tool_use and tool_selected ~= nil then
		HANDLERS[tool_selected.behaviour](tool_selected)
	end
end

UserInputService.InputBegan:Connect(on_input_began)
