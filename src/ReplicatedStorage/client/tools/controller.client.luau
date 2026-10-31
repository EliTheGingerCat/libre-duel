const Players = game:GetService("Players")
const UserInputService = game:GetService("UserInputService")

const editor_state = require(script.Parent.Parent.ui.hud.editor_state)
const KEYBINDS = require(script.Parent.Parent.util.KEYBINDS)
const LOADOUT = require(script.Parent.LOADOUT)
const registry = require(script.Parent.registry)
const state = require(script.Parent.state)
const table_flip = require(script.Parent.Parent.util.table_flip)
const tool_types = require(script.Parent.tool_types)

const player = Players.LocalPlayer
const key_to_slot = table_flip(KEYBINDS.slot)

local active_tool: tool_types.tool? = nil
local humanoid: Humanoid? = nil
local death_connection: RBXScriptConnection? = nil
local child_connection: RBXScriptConnection? = nil
local use_held = false

local function can_use(): boolean
	return not editor_state.enabled and humanoid ~= nil and humanoid.Health > 0
end

local function cancel_use(): ()
	use_held = false
	const tool = active_tool
	if tool and tool.cancel_use then
		tool.cancel_use()
	end
end

local function unequip(): ()
	const tool = active_tool
	active_tool = nil
	if tool == nil then
		return
	end
	if tool.cancel_use then
		tool.cancel_use()
	end
	if tool.unequip then
		tool.unequip()
	end
end

local function equip_selected(): ()
	unequip()
	const id: tool_types.id? = LOADOUT[state.current]
	if id == nil or humanoid == nil or humanoid.Health <= 0 then
		return
	end
	const tool = registry[id]()
	active_tool = tool
	if tool.equip then
		tool.equip()
	end
	if use_held and tool.buffer_click and can_use() then
		tool.begin_use()
	end
end

local function on_slot_changed(_slot: number): ()
	equip_selected()
end

local function on_input_began(input: InputObject, game_processed: boolean): ()
	if game_processed or not can_use() then
		return
	end
	const slot = key_to_slot[input.KeyCode]
	if slot then
		state.set_slot(slot)
	end
	if input.UserInputType == KEYBINDS.tool_use and not use_held then
		use_held = true
		const tool = active_tool
		if tool then
			tool.begin_use()
		end
	end
end

local function on_input_ended(input: InputObject, game_processed: boolean): ()
	if input.UserInputType ~= KEYBINDS.tool_use then
		return
	end
	const was_held = use_held
	use_held = false
	if game_processed or not can_use() then
		cancel_use()
		return
	end
	const tool = active_tool
	if was_held and tool and tool.end_use then
		tool.end_use()
	end
end

local function on_editor_changed(): ()
	if editor_state.enabled then
		cancel_use()
	end
end

local function on_died(): ()
	use_held = false
	unequip()
end

local function on_child_added(child: Instance): ()
	if humanoid ~= nil or not child:IsA("Humanoid") then
		return
	end
	humanoid = child
	death_connection = child.Died:Connect(on_died)
	equip_selected()
end

local function clear_character(): ()
	use_held = false
	unequip()
	humanoid = nil
	if death_connection then
		death_connection:Disconnect()
		death_connection = nil
	end
	if child_connection then
		child_connection:Disconnect()
		child_connection = nil
	end
end

local function on_character_added(character: Model): ()
	clear_character()
	child_connection = character.ChildAdded:Connect(on_child_added)
	const character_humanoid = character:FindFirstChildOfClass("Humanoid")
	if character_humanoid then
		on_child_added(character_humanoid)
	end
end

UserInputService.InputBegan:Connect(on_input_began)
UserInputService.InputEnded:Connect(on_input_ended)
UserInputService.WindowFocusReleased:Connect(cancel_use)
player.CharacterAdded:Connect(on_character_added)
player.CharacterRemoving:Connect(clear_character)
state.on_change:Connect(on_slot_changed)
editor_state.subscribe(on_editor_changed)

if player.Character then
	on_character_added(player.Character)
end
