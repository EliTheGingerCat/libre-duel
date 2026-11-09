local GuiService = game:GetService("GuiService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

const KEYBINDS = require(ReplicatedStorage.client.util.KEYBINDS)
local React = require(ReplicatedStorage.Packages.react)
local client_inventory_util = require(ReplicatedStorage.client.inventory.client_inventory_util)
local get_slot_at_position = require(script.Parent.get_slot_at_position)
local get_slot_tool = require(ReplicatedStorage.client.tools.get_slot_tool)
local inventory_logic = require(ReplicatedStorage.shared.inventory.inventory_logic)
local scale_animation_time = require(script.Parent.Parent.effects.scale_animation_time)
local table_flip = require(ReplicatedStorage.client.util.table_flip)

-- Moving further than this between press and release counts as a drag instead of a click.
const DRAG_THRESHOLD = 4
-- Matches the tween length in `use_ui_motion`, which animates the flying item.
const FLIGHT_DURATION = 0.28

type held = {
	slot: number,
	-- true while the mouse button is still down from picking the item up
	dragging: boolean,
	press_position: Vector2,
}

-- An item tweening into place after a shift click. Positions are slot centres in screen space.
export type flight = {
	id: number,
	image: string,
	to_slot: number,
	from: Vector2,
	to: Vector2,
	size: number,
}

export type inventory_input = {
	held_slot: number?,
	cursor: unknown,
	shake_count: number,
	flights: { flight },
}

local key_to_slot = table_flip(KEYBINDS.slot)

local function increment(current: number): number
	return current + 1
end

local function is_shift_down(): boolean
	return UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.RightShift)
end

local function get_mouse_position(): Vector2
	const inset = GuiService:GetGuiInset()
	return UserInputService:GetMouseLocation() - inset
end

local function get_slot_frame(window: GuiObject, slot: number): GuiObject?
	const frame = window:FindFirstChild(`slot_{slot}`, true)
	return if frame ~= nil and frame:IsA("GuiObject") then frame else nil
end

local function get_centre(object: GuiObject): Vector2
	return object.AbsolutePosition + object.AbsoluteSize / 2
end

local function is_inside(object: GuiObject, position: Vector2): boolean
	const corner = object.AbsolutePosition
	const size = object.AbsoluteSize
	return position.X >= corner.X
		and position.Y >= corner.Y
		and position.X <= corner.X + size.X
		and position.Y <= corner.Y + size.Y
end

--[[
Minecraft style controls:
- Click an item to pick it up, click another slot to put it there (swapping if it is taken).
- Or hold the mouse button and drag the item onto another slot.
- Shift click moves an item between the hotbar and the rest of the inventory.
- Pressing a hotbar number while hovering a slot swaps that slot with the hotbar slot.
- Crafting does not work yet, so clicking or dropping anything on it shakes it instead.
]]
local function use_inventory_input(window_ref: { current: GuiObject? }, enabled: boolean): inventory_input
	local held_slot: number?, set_held_slot: (number?) -> () = React.useState(nil :: number?)
	local shake_count, set_shake_count = React.useState(0)
	local flights: { flight }, set_flights: (({ flight }) -> { flight }) -> () = React.useState({} :: { flight })
	local next_flight_id = React.useRef(0)
	local cursor, set_cursor = React.useBinding(Vector2.zero)
	local held_ref = React.useRef(nil :: held?)

	local function subscribe()
		if not enabled then
			return
		end

		local function release(): ()
			held_ref.current = nil
			set_held_slot(nil)
		end

		local function hold(slot: number, position: Vector2): ()
			held_ref.current = { slot = slot, dragging = true, press_position = position }
			set_cursor(position)
			set_held_slot(slot)
		end

		local function shake(): ()
			set_shake_count(increment)
		end

		local function add_flight(new_flight: flight): ()
			local function append(current: { flight }): { flight }
				const copy = table.clone(current)
				table.insert(copy, new_flight)
				return copy
			end

			local function without(current: { flight }): { flight }
				const copy = table.clone(current)
				const index = table.find(copy, new_flight)
				if index ~= nil then
					table.remove(copy, index)
				end
				return copy
			end

			local function finish(): ()
				set_flights(without)
			end

			set_flights(append)
			task.delay(scale_animation_time(FLIGHT_DURATION), finish)
		end

		-- must run before the move, since it reads where the item is about to go
		local function start_flight(from_slot: number): ()
			const window = window_ref.current
			const inventory = client_inventory_util.get_inventory()
			const tool = get_slot_tool(from_slot)
			if window == nil or inventory == nil or tool == nil then
				return
			end
			const to_slot = inventory_logic.find_quick_move_slot(inventory, from_slot)
			if to_slot == nil then
				return
			end
			const from_frame = get_slot_frame(window, from_slot)
			const to_frame = get_slot_frame(window, to_slot)
			if from_frame == nil or to_frame == nil then
				return
			end
			next_flight_id.current += 1
			add_flight({
				id = next_flight_id.current,
				image = tool.image,
				to_slot = to_slot,
				from = get_centre(from_frame),
				to = get_centre(to_frame),
				size = to_frame.AbsoluteSize.X,
			})
		end

		local function drop(held: held, position: Vector2, moved: boolean): ()
			const window = window_ref.current
			const target = if window then get_slot_at_position(window, position) else nil
			if target == nil then
				-- clicking empty space inside the window keeps the item, anywhere else puts it back
				if held.dragging or window == nil or not is_inside(window, position) then
					release()
				end
				return
			end
			if target.kind == "crafting" then
				shake()
				if held.dragging then
					release()
				end
				return
			end
			if target.index == held.slot then
				if held.dragging and not moved then
					-- a plain click picks the item up and it follows the cursor until the next click
					held.dragging = false
				else
					release()
				end
				return
			end
			client_inventory_util.swap_items(held.slot, target.index)
			release()
		end

		local function on_mouse_down(position: Vector2): ()
			const held = held_ref.current
			if held ~= nil then
				drop(held, position, true)
				return
			end
			const window = window_ref.current
			const target = if window then get_slot_at_position(window, position) else nil
			if target ~= nil and target.kind == "crafting" then
				shake()
				return
			end
			if target == nil or get_slot_tool(target.index) == nil then
				return
			end
			if is_shift_down() then
				start_flight(target.index)
				client_inventory_util.quick_move(target.index)
				return
			end
			hold(target.index, position)
		end

		local function on_mouse_up(position: Vector2): ()
			const held = held_ref.current
			if held == nil or not held.dragging then
				return
			end
			drop(held, position, (position - held.press_position).Magnitude > DRAG_THRESHOLD)
		end

		local function on_number_key(hotbar_slot: number): ()
			const window = window_ref.current
			if held_ref.current ~= nil or window == nil or UserInputService:GetFocusedTextBox() ~= nil then
				return
			end
			const target = get_slot_at_position(window, get_mouse_position())
			if target == nil or target.kind ~= "inventory" or target.index == hotbar_slot then
				return
			end
			client_inventory_util.swap_items(target.index, hotbar_slot)
		end

		local function on_input_began(input: InputObject): ()
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				on_mouse_down(Vector2.new(input.Position.X, input.Position.Y))
				return
			end
			const hotbar_slot: number? = key_to_slot[input.KeyCode]
			if hotbar_slot ~= nil then
				on_number_key(hotbar_slot)
			end
		end

		local function on_input_ended(input: InputObject): ()
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				on_mouse_up(Vector2.new(input.Position.X, input.Position.Y))
			end
		end

		local function on_input_changed(input: InputObject): ()
			if input.UserInputType == Enum.UserInputType.MouseMovement then
				set_cursor(Vector2.new(input.Position.X, input.Position.Y))
			end
		end

		-- a server rollback can empty the held slot
		local function on_inventory_change(): ()
			const held = held_ref.current
			if held ~= nil and get_slot_tool(held.slot) == nil then
				release()
			end
		end

		local connection_began = UserInputService.InputBegan:Connect(on_input_began)
		local connection_ended = UserInputService.InputEnded:Connect(on_input_ended)
		local connection_changed = UserInputService.InputChanged:Connect(on_input_changed)
		local connection_inventory = client_inventory_util.on_change:Connect(on_inventory_change)

		local function disconnect(): ()
			connection_began:Disconnect()
			connection_ended:Disconnect()
			connection_changed:Disconnect()
			connection_inventory:Disconnect()
			release()
		end

		return disconnect
	end

	React.useEffect(subscribe, { enabled })

	return { held_slot = held_slot, cursor = cursor, shake_count = shake_count, flights = flights }
end

return use_inventory_input
