local ReplicatedStorage = game:GetService("ReplicatedStorage")

const COLOURS = require(ReplicatedStorage.shared.ui.COLOURS)
const INVENTORY_CONSTANTS = require(ReplicatedStorage.shared.inventory.INVENTORY_CONSTANTS)
const INVENTORY_LAYOUT = require(script.Parent.INVENTORY_LAYOUT)
local React = require(ReplicatedStorage.Packages.react)
const get_slot_amount = require(ReplicatedStorage.client.tools.get_slot_amount)
local get_slot_tool = require(ReplicatedStorage.client.tools.get_slot_tool)
local gradient_stroke = require(script.Parent.Parent.visuals.gradient_stroke)
local item_amount = require(script.Parent.item_amount)
local item_slot = require(script.Parent.item_slot)
local mount_paperdoll = require(script.Parent.Parent.hud.mount_paperdoll)
local ui_blur = require(script.Parent.Parent.blur.ui_blur)
local shadow = require(script.Parent.Parent.visuals.shadow)
local slot_box = require(script.Parent.slot_box)
local use_inventory_input = require(script.Parent.use_inventory_input)
local use_inventory_toggle = require(script.Parent.use_inventory_toggle)
local use_inventory_version = require(script.Parent.use_inventory_version)
local use_shake = require(script.Parent.use_shake)
local use_ui_motion = require(script.Parent.Parent.visuals.use_ui_motion)
local use_viewport_scale = require(script.Parent.Parent.visuals.use_viewport_scale)

local create_element = React.createElement

const ARROW_IMAGE = "rbxassetid://84702625541122"
const CRAFTING_COLUMNS = 2
const CRAFTING_SLOTS = 4
const PAPERDOLL_SIZE = Vector2.new(200, 300)
const SECTION_GAP = 20
-- Space kept free around the window so it never touches the screen edges.
const SCREEN_MARGIN = 16

-- The length of a slot box spanning `cells` slots, padding included.
local function get_box_length(cells: number): number
	return cells * INVENTORY_LAYOUT.SLOT_SIZE
		+ (cells - 1) * INVENTORY_LAYOUT.SLOT_GAP
		+ INVENTORY_LAYOUT.BOX_PADDING * 2
end

const SLOTS_WIDTH = get_box_length(INVENTORY_CONSTANTS.COLUMNS)
-- Each crafting box is its slots plus padding, laid out as inputs, arrow, output.
const CRAFTING_INPUTS_SIZE = get_box_length(CRAFTING_COLUMNS)
const CRAFTING_OUTPUT_SIZE = INVENTORY_LAYOUT.SLOT_SIZE + INVENTORY_LAYOUT.BOX_PADDING * 2
const CRAFTING_SIZE = Vector2.new(
	CRAFTING_INPUTS_SIZE + INVENTORY_LAYOUT.SLOT_SIZE + CRAFTING_OUTPUT_SIZE + INVENTORY_LAYOUT.BOX_PADDING * 2,
	CRAFTING_INPUTS_SIZE
)
-- The window sizes itself automatically, but fitting it to the screen needs its size up front.
const WINDOW_SIZE = Vector2.new(
	SLOTS_WIDTH,
	PAPERDOLL_SIZE.Y
		+ SECTION_GAP
		+ get_box_length(INVENTORY_CONSTANTS.ROWS - 1)
		+ INVENTORY_LAYOUT.BOX_PADDING
		+ get_box_length(1)
) + Vector2.one * INVENTORY_LAYOUT.BOX_PADDING * 2

-- Held items and items still flying into place are drawn elsewhere, so their slots look empty.
local function get_hidden_slots(input: use_inventory_input.inventory_input): { [number]: boolean }
	const hidden: { [number]: boolean } = {}
	if input.held_slot ~= nil then
		hidden[input.held_slot] = true
	end
	for _, flight in input.flights do
		hidden[flight.to_slot] = true
	end
	return hidden
end

local function get_slot_image(slot: number, hidden_slots: { [number]: boolean }): string?
	if hidden_slots[slot] then
		return nil
	end
	const tool = get_slot_tool(slot)
	return if tool ~= nil then tool.image else nil
end

local function inventory_slots(props: { first: number, last: number, hidden_slots: { [number]: boolean } })
	local slots = {}
	for slot = props.first, props.last do
		slots[slot] = create_element(item_slot, {
			name = `slot_{slot}`,
			image = get_slot_image(slot, props.hidden_slots),
			amount = if props.hidden_slots[slot] then nil else get_slot_amount(slot),
			layout_order = slot,
		})
	end
	return create_element(React.Fragment, {}, slots)
end

local function paperdoll(props: { enabled: boolean })
	local viewport_ref = React.useRef(nil :: ViewportFrame?)

	-- Only render the character while the window is open.
	local function mount()
		const viewport = viewport_ref.current
		if not props.enabled or viewport == nil then
			return
		end
		return mount_paperdoll(viewport)
	end

	React.useLayoutEffect(mount, { props.enabled })

	return create_element("CanvasGroup", {
		BackgroundColor3 = COLOURS.surface,
		BackgroundTransparency = 0.5,
		LayoutOrder = 0,
		Name = "paperdoll",
		Size = UDim2.fromOffset(PAPERDOLL_SIZE.X, PAPERDOLL_SIZE.Y),
	}, {
		corner = create_element("UICorner", { CornerRadius = UDim.new(0, INVENTORY_LAYOUT.WINDOW_RADIUS) }),
		shadow = create_element(shadow, { ShowBehindParent = false, BlurRadius = UDim.new(0, 8), Transparency = 0.3 }),
		stroke = create_element(gradient_stroke),
		viewport = create_element("ViewportFrame", {
			ref = viewport_ref,
			Ambient = Color3.new(200 / 255, 200 / 255, 200 / 255),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			LightColor = Color3.new(140 / 255, 140 / 255, 140 / 255),
			Name = "viewport",
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(1, 1),
		}),
	})
end

-- The crafting area is only a placeholder for now, it does not hold items. It shakes when clicked instead.
-- Its wrapper has a fixed size so shaking does not move the layout.
local function crafting(props: { shake_count: number })
	local offset = use_shake(props.shake_count)

	local function to_position(value: number): UDim2
		return UDim2.fromOffset(value, 0)
	end

	local inputs = {}
	for index = 1, CRAFTING_SLOTS do
		inputs[index] = create_element(item_slot, { name = `crafting_input_{index}`, layout_order = index })
	end

	return create_element("Frame", {
		BackgroundTransparency = 1,
		LayoutOrder = 1,
		Name = "crafting",
		Size = UDim2.fromOffset(CRAFTING_SIZE.X, CRAFTING_SIZE.Y),
	}, {
		content = create_element("Frame", {
			AutomaticSize = Enum.AutomaticSize.XY,
			BackgroundTransparency = 1,
			Name = "crafting_content",
			Position = offset:map(to_position),
			Size = UDim2.fromOffset(0, 0),
		}, {
			layout = create_element("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				Padding = UDim.new(0, INVENTORY_LAYOUT.BOX_PADDING),
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Center,
			}),
			inputs = create_element(slot_box, {
				name = "crafting_inputs",
				columns = CRAFTING_COLUMNS,
				count = CRAFTING_SLOTS,
				layout_order = 1,
			}, inputs),
			arrow = create_element("ImageLabel", {
				BackgroundTransparency = 1,
				Image = ARROW_IMAGE,
				LayoutOrder = 2,
				Name = "crafting_arrow",
				Size = UDim2.fromOffset(INVENTORY_LAYOUT.SLOT_SIZE, INVENTORY_LAYOUT.SLOT_SIZE),
			}),
			output = create_element(slot_box, {
				name = "crafting_output_box",
				columns = 1,
				count = 1,
				layout_order = 3,
			}, {
				slot = create_element(item_slot, { name = "crafting_output", layout_order = 1 }),
			}),
		}),
	})
end

-- A loose item drawn over the window, with the same icon and counter as a slot. `size` is the slot size in pixels.
local function floating_item(props: { name: string, image: string, amount: number?, size: number, position: unknown })
	return create_element("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Name = props.name,
		Position = props.position :: any,
		Size = UDim2.fromOffset(props.size, props.size),
		ZIndex = 10,
	}, {
		icon = create_element("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Image = props.image,
			Name = "icon",
			Position = UDim2.fromScale(0.5, 0.5),
			ScaleType = Enum.ScaleType.Fit,
			Size = UDim2.fromScale(INVENTORY_LAYOUT.ICON_SCALE, INVENTORY_LAYOUT.ICON_SCALE),
		}),
		amount = create_element(item_amount, { amount = props.amount }),
	})
end

local function held_item(props: { held_slot: number?, cursor: unknown, scale: number })
	const tool = if props.held_slot ~= nil then get_slot_tool(props.held_slot) else nil
	if props.held_slot == nil or tool == nil then
		return nil
	end

	local function to_position(position: Vector2): UDim2
		return UDim2.fromOffset(position.X, position.Y)
	end

	return create_element(floating_item, {
		name = "held_item",
		image = tool.image,
		amount = get_slot_amount(props.held_slot),
		size = INVENTORY_LAYOUT.SLOT_SIZE * props.scale,
		position = (props.cursor :: any):map(to_position),
	})
end

local function flying_item(props: { flight: use_inventory_input.flight })
	local progress = use_ui_motion(1, 0, 0)
	const flight = props.flight

	local function to_position(value: number): UDim2
		const position = flight.from:Lerp(flight.to, value)
		return UDim2.fromOffset(position.X, position.Y)
	end

	return create_element(floating_item, {
		name = "flying_item",
		image = flight.image,
		amount = flight.amount,
		size = flight.size,
		position = progress:map(to_position),
	})
end

local function flying_items(props: { flights: { use_inventory_input.flight } })
	local items = {}
	for _, flight in props.flights do
		items[`flight_{flight.id}`] = create_element(flying_item, { flight = flight })
	end
	return create_element(React.Fragment, {}, items)
end

local function inventory()
	local enabled = use_inventory_toggle()
	local window_ref = React.useRef(nil :: GuiObject?)
	local input = use_inventory_input(window_ref, enabled)
	const hidden_slots = get_hidden_slots(input)
	use_inventory_version()
	local viewport_scale = use_viewport_scale()
	local screen_ref = React.useRef(nil :: ScreenGui?)
	local fit, set_fit = React.useState(1)

	-- The viewport scale is tuned for the HUD, so the window can still overflow short screens like phones without this.
	local function track_fit()
		local screen = screen_ref.current
		assert(screen)
		local function update(): ()
			local available = screen.AbsoluteSize - Vector2.one * SCREEN_MARGIN * 2
			if available.X > 0 and available.Y > 0 then
				set_fit(math.min(available.X / WINDOW_SIZE.X, available.Y / WINDOW_SIZE.Y))
			end
		end
		local connection = screen:GetPropertyChangedSignal("AbsoluteSize"):Connect(update)
		update()
		local function disconnect(): ()
			connection:Disconnect()
		end
		return disconnect
	end
	React.useLayoutEffect(track_fit, { enabled })
	const window_scale = math.min(viewport_scale, fit)

	return create_element("ScreenGui", {
		ref = screen_ref,
		DisplayOrder = 10,
		Enabled = enabled,
		Name = "Inventory",
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	}, {
		-- A TextButton so clicks inside the window do not reach the game.
		window = create_element("TextButton", {
			ref = window_ref,
			AnchorPoint = Vector2.new(0.5, 0.5),
			AutoButtonColor = false,
			AutomaticSize = Enum.AutomaticSize.XY,
			BackgroundColor3 = COLOURS.surface,
			BackgroundTransparency = 0.5,
			Name = "window",
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(0, 0),
			Text = "",
		}, {
			corner = create_element("UICorner", { CornerRadius = UDim.new(0, INVENTORY_LAYOUT.WINDOW_RADIUS) }),
			layout = create_element("UIListLayout", {
				Padding = UDim.new(0, SECTION_GAP),
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),
			padding = create_element("UIPadding", {
				PaddingBottom = UDim.new(0, INVENTORY_LAYOUT.BOX_PADDING),
				PaddingLeft = UDim.new(0, INVENTORY_LAYOUT.BOX_PADDING),
				PaddingRight = UDim.new(0, INVENTORY_LAYOUT.BOX_PADDING),
				PaddingTop = UDim.new(0, INVENTORY_LAYOUT.BOX_PADDING),
			}),
			scale = create_element("UIScale", { Scale = window_scale }),
			shadow = create_element(
				shadow,
				{ ShowBehindParent = false, BlurRadius = UDim.new(0, 8), Transparency = 0.3 }
			),
			stroke = create_element(gradient_stroke),
			blur = enabled and create_element(ui_blur),
			top = create_element("Frame", {
				BackgroundTransparency = 1,
				LayoutOrder = 0,
				Name = "top",
				Size = UDim2.fromOffset(SLOTS_WIDTH, PAPERDOLL_SIZE.Y),
			}, {
				layout = create_element("UIListLayout", {
					FillDirection = Enum.FillDirection.Horizontal,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					Padding = UDim.new(0, INVENTORY_LAYOUT.SLOT_SIZE),
					SortOrder = Enum.SortOrder.LayoutOrder,
					VerticalAlignment = Enum.VerticalAlignment.Center,
				}),
				paperdoll = create_element(paperdoll, { enabled = enabled }),
				crafting = create_element(crafting, { shake_count = input.shake_count }),
			}),
			slots = create_element("Frame", {
				AutomaticSize = Enum.AutomaticSize.XY,
				BackgroundTransparency = 1,
				LayoutOrder = 1,
				Name = "slots",
				Size = UDim2.fromOffset(0, 0),
			}, {
				layout = create_element("UIListLayout", {
					Padding = UDim.new(0, INVENTORY_LAYOUT.BOX_PADDING),
					SortOrder = Enum.SortOrder.LayoutOrder,
				}),
				non_hotbar_slots = create_element(slot_box, {
					name = "non_hotbar_slots",
					columns = INVENTORY_CONSTANTS.COLUMNS,
					count = INVENTORY_CONSTANTS.INVENTORY_SIZE - INVENTORY_CONSTANTS.COLUMNS,
					layout_order = 0,
				}, {
					slots = create_element(inventory_slots, {
						first = INVENTORY_CONSTANTS.COLUMNS + 1,
						last = INVENTORY_CONSTANTS.INVENTORY_SIZE,
						hidden_slots = hidden_slots,
					}),
				}),
				hotbar_slots = create_element(slot_box, {
					name = "hotbar_slots",
					columns = INVENTORY_CONSTANTS.COLUMNS,
					count = INVENTORY_CONSTANTS.COLUMNS,
					layout_order = 1,
				}, {
					slots = create_element(inventory_slots, {
						first = 1,
						last = INVENTORY_CONSTANTS.COLUMNS,
						hidden_slots = hidden_slots,
					}),
				}),
			}),
		}),
		held_item = create_element(
			held_item,
			{ held_slot = input.held_slot, cursor = input.cursor, scale = window_scale }
		),
		flying_items = create_element(flying_items, { flights = input.flights }),
	})
end

return inventory
