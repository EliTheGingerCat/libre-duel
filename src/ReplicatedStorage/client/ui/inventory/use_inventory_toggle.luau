local ContextActionService = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

const GAMEPAD_KEYBINDS = require(ReplicatedStorage.client.util.GAMEPAD_KEYBINDS)
const KEYBINDS = require(ReplicatedStorage.client.util.KEYBINDS)
local React = require(ReplicatedStorage.Packages.react)
local client_inventory_util = require(ReplicatedStorage.client.inventory.client_inventory_util)
local editor_state = require(script.Parent.Parent.hud.editor_state)
local inventory_state = require(script.Parent.inventory_state)
local mode_selector_state = require(script.Parent.Parent.matchmaking.mode_selector_state)
local viewed_inventory = require(ReplicatedStorage.client.inventory.viewed_inventory)

const BLOCK_CAMERA_ACTION = "inventory_block_camera"
const GAMEPAD_CLOSE_ACTION = "inventory_gamepad_close"

const function close(): ()
	inventory_state.set_enabled(false)
end

const function sink(): Enum.ContextActionResult
	return Enum.ContextActionResult.Sink
end

-- bound through ContextActionService so the press reaches everything else as game processed, otherwise B would also start sneaking
const function close_from_gamepad(_action_name: string, input_state: Enum.UserInputState): Enum.ContextActionResult
	if input_state == Enum.UserInputState.Begin then
		close()
	end
	return Enum.ContextActionResult.Sink
end

-- Opens and closes the inventory with its keybind. It closes on escape, on death, and when another menu opens.
const function use_inventory_toggle(): boolean
	local enabled, set_enabled = React.useState(inventory_state.enabled)

	const function subscribe()
		const function update(): ()
			-- the inventory of another player stays open without a local one, such as while dead
			const nothing_to_show = client_inventory_util.get_inventory() == nil and viewed_inventory.get_target() == nil
			if editor_state.enabled or mode_selector_state.enabled or nothing_to_show then
				close()
			end
			set_enabled(inventory_state.enabled)
		end

		const function on_input(input: InputObject, processed: boolean): ()
			if processed or UserInputService:GetFocusedTextBox() ~= nil then
				return
			end
			if input.KeyCode == KEYBINDS.inventory or input.KeyCode == GAMEPAD_KEYBINDS.inventory then
				inventory_state.set_enabled(not inventory_state.enabled)
				update()
			elseif input.KeyCode == Enum.KeyCode.Escape then
				close()
			end
		end

		local connection = inventory_state.on_change:Connect(update)
		local connection_input = UserInputService.InputBegan:Connect(on_input)
		local connection_inventory = viewed_inventory.on_change:Connect(update)
		local connection_mode_selector = mode_selector_state.on_change:Connect(update)
		local unsubscribe_editor = editor_state.subscribe(update)
		update()

		const function disconnect(): ()
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

	-- holding right click can still pan the camera while the cursor is free, and B closes instead of sneaking
	const function bind_open_actions()
		if not enabled then
			return
		end
		ContextActionService:BindActionAtPriority(
			BLOCK_CAMERA_ACTION,
			sink,
			false,
			Enum.ContextActionPriority.High.Value,
			Enum.UserInputType.MouseButton2
		)
		ContextActionService:BindActionAtPriority(
			GAMEPAD_CLOSE_ACTION,
			close_from_gamepad,
			false,
			Enum.ContextActionPriority.High.Value,
			GAMEPAD_KEYBINDS.menu_close
		)

		const function unbind(): ()
			ContextActionService:UnbindAction(BLOCK_CAMERA_ACTION)
			ContextActionService:UnbindAction(GAMEPAD_CLOSE_ACTION)
		end

		return unbind
	end

	React.useEffect(bind_open_actions, { enabled })

	return enabled
end

return use_inventory_toggle
