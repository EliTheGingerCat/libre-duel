local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

const KEYBINDS = require(ReplicatedStorage.client.util.KEYBINDS)
local React = require(ReplicatedStorage.Packages.react)
local client_inventory_util = require(ReplicatedStorage.client.inventory.client_inventory_util)
local editor_state = require(script.Parent.Parent.hud.editor_state)
local inventory_state = require(script.Parent.inventory_state)
local mode_selector_state = require(script.Parent.Parent.matchmaking.mode_selector_state)

local function close(): ()
	inventory_state.set_enabled(false)
end

-- Opens and closes the inventory with its keybind. It closes on escape, on death, and when another menu opens.
local function use_inventory_toggle(): boolean
	local enabled, set_enabled = React.useState(inventory_state.enabled)

	local function subscribe()
		local function update(): ()
			if editor_state.enabled or mode_selector_state.enabled or client_inventory_util.get_inventory() == nil then
				close()
			end
			set_enabled(inventory_state.enabled)
		end

		local function on_input(input: InputObject, processed: boolean): ()
			if processed or UserInputService:GetFocusedTextBox() ~= nil then
				return
			end
			if input.KeyCode == KEYBINDS.inventory then
				inventory_state.set_enabled(not inventory_state.enabled)
				update()
			elseif input.KeyCode == Enum.KeyCode.Escape then
				close()
			end
		end

		local connection = inventory_state.on_change:Connect(update)
		local connection_input = UserInputService.InputBegan:Connect(on_input)
		local connection_inventory = client_inventory_util.on_change:Connect(update)
		local connection_mode_selector = mode_selector_state.on_change:Connect(update)
		local unsubscribe_editor = editor_state.subscribe(update)
		update()

		local function disconnect(): ()
			connection:Disconnect()
			connection_input:Disconnect()
			connection_inventory:Disconnect()
			connection_mode_selector:Disconnect()
			unsubscribe_editor()
			close()
		end

		return disconnect
	end

	React.useEffect(subscribe, {})

	return enabled
end

return use_inventory_toggle
