const ReplicatedStorage = game:GetService("ReplicatedStorage")
const UserInputService = game:GetService("UserInputService")

const editor_state = require(ReplicatedStorage.client.ui.hud.editor_state)
const inventory_state = require(ReplicatedStorage.client.ui.inventory.inventory_state)
const KEYBINDS = require(ReplicatedStorage.client.util.KEYBINDS)
const mode_selector_state = require(ReplicatedStorage.client.ui.matchmaking.mode_selector_state)
const slot_has_behaviour = require(script.Parent.Parent.slot_has_behaviour)
const tool_state = require(script.Parent.Parent.tool_state)

-- suffixing _remote to not confuse roblo
const update_blocking_remote = ReplicatedStorage.remotes.update_blocking

local block_held: boolean = false

-- buffer clicks support
local function update_blocking(): ()
	const blocking = block_held and slot_has_behaviour(tool_state.current, "sword")
	if blocking == tool_state.blocking then
		return
	end
	tool_state.blocking = blocking
	tool_state.on_block_change:Fire(blocking)
	update_blocking_remote:InvokeServer(blocking)
end

local function on_input_began(input: InputObject, game_processed: boolean): ()
	if input.UserInputType ~= KEYBINDS.tool_block then
		return
	end
	if game_processed or editor_state.enabled or inventory_state.enabled or mode_selector_state.enabled then
		return
	end
	block_held = true
	update_blocking()
end

local function on_input_ended(input: InputObject): ()
	if input.UserInputType ~= KEYBINDS.tool_block then
		return
	end
	block_held = false
	update_blocking()
end

tool_state.on_change:Connect(update_blocking)
UserInputService.InputBegan:Connect(on_input_began)
UserInputService.InputEnded:Connect(on_input_ended)
