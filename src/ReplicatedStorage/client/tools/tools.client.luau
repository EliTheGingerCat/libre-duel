const Players = game:GetService("Players")
const ReplicatedStorage = game:GetService("ReplicatedStorage")
const UserInputService = game:GetService("UserInputService")

const attack_melee = require(ReplicatedStorage.client.combat.attack_melee)
const block_sword = require(script.Parent.sword.block_sword)
const client_inventory_util = require(ReplicatedStorage.client.inventory.client_inventory_util)
const create_tool_button = require(script.Parent.create_tool_button)
const eat_cake = require(script.Parent.cake.eat_cake)
const editor_state = require(ReplicatedStorage.client.ui.hud.editor_state)
const GAMEPAD_KEYBINDS = require(ReplicatedStorage.client.util.GAMEPAD_KEYBINDS)
const get_cycled_slot = require(script.Parent.get_cycled_slot)
const get_slot_tool = require(script.Parent.get_slot_tool)
const inventory_state = require(ReplicatedStorage.client.ui.inventory.inventory_state)
const KEYBINDS = require(ReplicatedStorage.client.util.KEYBINDS)
const mine_cube = require(script.Parent.pickaxe.mine_cube)
const mode_selector_state = require(ReplicatedStorage.client.ui.matchmaking.mode_selector_state)
const open_mode_selector = require(script.Parent.mode_selector.open_mode_selector)
const place_cube = require(script.Parent.cube.place_cube)
const pull_bow = require(script.Parent.bow.pull_bow)
const STARTING_LOADOUT = require(ReplicatedStorage.shared.inventory.STARTING_LOADOUT)
const table_flip = require(ReplicatedStorage.client.util.table_flip)
const tool_state = require(script.Parent.tool_state)
const tool_types = require(ReplicatedStorage.shared.tools.tool_types)

const select_slot = ReplicatedStorage.remotes.select_slot

const local_player = Players.LocalPlayer

const INPUT_TO_BUTTON: { [Enum.UserInputType]: string } = {
	[KEYBINDS.tool_attack] = "attack",
	[KEYBINDS.tool_use] = "use",
}

const GAMEPAD_KEY_TO_BUTTON: { [Enum.KeyCode]: string } = {
	[GAMEPAD_KEYBINDS.tool_attack] = "attack",
	[GAMEPAD_KEYBINDS.tool_use] = "use",
}

const GAMEPAD_KEY_TO_SLOT_STEP: { [Enum.KeyCode]: number } = {
	[GAMEPAD_KEYBINDS.slot_next] = 1,
	[GAMEPAD_KEYBINDS.slot_previous] = -1,
}

const TOOL_BUTTONS = {
	-- attacking isn't listed because every tool does it
	attack = create_tool_button({
		pickaxe = mine_cube,
	}),
	use = create_tool_button({
		bow = pull_bow,
		cake = eat_cake,
		cube = { start = place_cube },
		mode_selector = { start = open_mode_selector },
		sword = block_sword,
	}),
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
	for _, tool_button in TOOL_BUTTONS do
		tool_button.on_tool_changed(tool_selected)
	end
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

const function get_input_button(input: InputObject): string?
	return INPUT_TO_BUTTON[input.UserInputType] or GAMEPAD_KEY_TO_BUTTON[input.KeyCode]
end

local function press_button(button: string): ()
	if editor_state.enabled or inventory_state.enabled or mode_selector_state.enabled then
		return
	end
	const tool_button = TOOL_BUTTONS[button]
	if tool_button == nil then
		return
	end

	-- an empty hand presses too, so that switching to a tool while still holding the button uses it
	tool_button.press(tool_selected)

	if tool_selected == nil then
		return
	end

	if button == "attack" then
		tool_state.on_attack:Fire()
		attack_melee()
	elseif button == "use" then
		tool_state.on_use:Fire()
	end
end

-- letting go over UI cancels the handler instead of finishing it, otherwise it would shoot the bow
local function release_button(button: string, interrupted: boolean): ()
	const tool_button = TOOL_BUTTONS[button]
	if tool_button == nil then
		return
	end
	if interrupted then
		tool_button.interrupt()
	else
		tool_button.release()
	end
end

local function on_input_began(input: InputObject, game_processed: boolean): ()
	-- the inventory uses the number keys and clicks itself
	if game_processed or editor_state.enabled or inventory_state.enabled then
		return
	end

	local slot: number? = key_to_slot[input.KeyCode]
	if slot ~= nil then
		set_tool(slot)
	end

	const slot_step = GAMEPAD_KEY_TO_SLOT_STEP[input.KeyCode]
	if slot_step ~= nil then
		set_tool(get_cycled_slot(tool_state.current, slot_step))
	end

	const button = get_input_button(input)
	if button ~= nil then
		press_button(button)
	end
end

local function on_input_ended(input: InputObject, game_processed: boolean): ()
	const button = get_input_button(input)
	if button ~= nil then
		release_button(button, game_processed)
	end
end

local function on_button_requested(button: string, is_pressed: boolean): ()
	if is_pressed then
		press_button(button)
	else
		release_button(button, false)
	end
end

local function interrupt_tool_buttons(): ()
	for _, tool_button in TOOL_BUTTONS do
		tool_button.interrupt()
	end
end

local function on_menu_change(): ()
	if editor_state.enabled or inventory_state.enabled or mode_selector_state.enabled then
		interrupt_tool_buttons()
	end
end

UserInputService.InputBegan:Connect(on_input_began)
UserInputService.InputEnded:Connect(on_input_ended)
UserInputService.WindowFocusReleased:Connect(interrupt_tool_buttons)
local_player.CharacterRemoving:Connect(interrupt_tool_buttons)
inventory_state.on_change:Connect(on_menu_change)
mode_selector_state.on_change:Connect(on_menu_change)
editor_state.subscribe(on_menu_change)
tool_state.on_button_requested:Connect(on_button_requested)
