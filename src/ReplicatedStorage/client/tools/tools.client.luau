local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

const KEYBINDS = require(ReplicatedStorage.client.util.KEYBINDS)
const STARTING_LOADOUT = require(ReplicatedStorage.shared.inventory.STARTING_LOADOUT)
local attack_melee = require(script.Parent.sword.attack_melee)
local client_inventory_util = require(ReplicatedStorage.client.inventory.client_inventory_util)
local mine_cube = require(script.Parent.pickaxe.mine_cube)
local eat_cake = require(script.Parent.cake.eat_cake)
local editor_state = require(ReplicatedStorage.client.ui.hud.editor_state)
local get_slot_tool = require(script.Parent.get_slot_tool)
local inventory_state = require(ReplicatedStorage.client.ui.inventory.inventory_state)
local mode_selector_state = require(ReplicatedStorage.client.ui.matchmaking.mode_selector_state)
local open_mode_selector = require(script.Parent.mode_selector.open_mode_selector)
local place_cube = require(script.Parent.cube.place_cube)
local pull_bow = require(script.Parent.bow.pull_bow)
local table_flip = require(ReplicatedStorage.client.util.table_flip)
local tool_registry = require(ReplicatedStorage.shared.tools.registry)
local tool_types = require(ReplicatedStorage.shared.tools.tool_types)
local tool_state = require(script.Parent.tool_state)

const select_slot = ReplicatedStorage.remotes.select_slot

const HANDLERS: { [tool_types.behaviour]: (tool: tool_types.tool) -> () } = {
	bow = pull_bow,
	cake = eat_cake,
	cube = place_cube,
	pickaxe = mine_cube,
	mode_selector = open_mode_selector,
	sword = attack_melee,
}

local tool_selected: tool_types.tool? = nil
local slot_sent: number? = nil

local function set_tool(slot: number): ()
	tool_selected = get_slot_tool(slot)
	-- the server only lets us use the tool in the slot it thinks is selected
	if slot ~= slot_sent then
		slot_sent = slot
		select_slot:FireServer(slot)
	end
	tool_state.current = slot
	tool_state.on_change:Fire(slot)
end

local tool_cube = table.find(STARTING_LOADOUT, "cube")
set_tool(tool_cube or 1)

-- the selected slot's item can change underneath us (swaps, respawn, death)
local function on_inventory_change(): ()
	if get_slot_tool(tool_state.current) ~= tool_selected then
		set_tool(tool_state.current)
	end
end

client_inventory_util.on_change:Connect(on_inventory_change)
tool_state.on_select_requested:Connect(set_tool)

local key_to_slot = table_flip(KEYBINDS.slot)

local function on_input_began(input: InputObject, game_processed: boolean): ()
	-- the inventory uses the number keys and clicks itself
	if game_processed or editor_state.enabled or inventory_state.enabled then
		return
	end

	local slot: number? = key_to_slot[input.KeyCode]
	if slot ~= nil then
		set_tool(slot)
	end

	if mode_selector_state.enabled then
		return
	end

	-- handlers can yield, and using up the item changes tool_selected while they wait
	const tool = tool_selected
	if input.UserInputType == KEYBINDS.tool_use and tool ~= nil then
		tool_state.on_use:Fire(tool)
		for behaviour: tool_types.behaviour, handler in HANDLERS do
			if tool_registry.has_behaviour(tool, behaviour) then
				handler(tool)
			end
		end
	end
end

UserInputService.InputBegan:Connect(on_input_began)
