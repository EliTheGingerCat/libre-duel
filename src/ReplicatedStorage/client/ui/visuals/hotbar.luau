local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

const COLOURS = require(ReplicatedStorage.shared.ui.COLOURS)
const FONTS = require(ReplicatedStorage.shared.ui.FONTS)
const INVENTORY_CONSTANTS = require(ReplicatedStorage.shared.inventory.INVENTORY_CONSTANTS)
const INVENTORY_LAYOUT = require(script.Parent.Parent.inventory.INVENTORY_LAYOUT)
local React = require(ReplicatedStorage.Packages.react)
local get_slot_tool = require(ReplicatedStorage.client.tools.get_slot_tool)
local gradient_stroke = require(script.Parent.gradient_stroke)
local hud_screen = require(script.Parent.Parent.hud.hud_screen)
local ui_blur = require(script.Parent.Parent.blur.ui_blur)
local inventory_state = require(script.Parent.Parent.inventory.inventory_state)
local item_slot = require(script.Parent.Parent.inventory.item_slot)
local scale = require(script.Parent.scale)
local shadow = require(script.Parent.shadow)
local tool_state = require(ReplicatedStorage.client.tools.tool_state)
local use_editable_hud = require(script.Parent.Parent.hud.use_editable_hud)
local use_inventory_version = require(script.Parent.Parent.inventory.use_inventory_version)

local create_element = React.createElement
local local_player = Players.LocalPlayer
local use_effect = React.useEffect
local use_state = React.useState

-- The hotbar grows with the column count, and the health bar matches its width.
const SLOTS_WIDTH = INVENTORY_CONSTANTS.COLUMNS * INVENTORY_LAYOUT.SLOT_SIZE
	+ (INVENTORY_CONSTANTS.COLUMNS - 1) * INVENTORY_LAYOUT.HOTBAR_SLOT_GAP
	+ INVENTORY_LAYOUT.HOTBAR_PADDING * 2
const SLOTS_HEIGHT = INVENTORY_LAYOUT.SLOT_SIZE + INVENTORY_LAYOUT.HOTBAR_PADDING * 2
const HEALTH_WIDTH = SLOTS_WIDTH - INVENTORY_LAYOUT.HOTBAR_PADDING
const HEALTH_HEIGHT = 26

local function slider_display(props: {
	anchor_point: Vector2,
	colour_background: Color3,
	colour_gradient: ColorSequence,
	colour_stroke: Color3,
	fill_total: number,
	fill_value: number,
	name: string,
	position: UDim2,
	size: UDim2,
})
	return create_element(
		"Frame",
		{
			AnchorPoint = props.anchor_point,
			BackgroundColor3 = props.colour_background,
			Name = props.name,
			Position = props.position,
			Size = props.size,
		},
		create_element("UICorner", {
			CornerRadius = UDim.new(0.45, 0),
		}),
		create_element("UIStroke", {
			Thickness = 1,
			Color = props.colour_stroke,
			ApplyStrokeMode = "Border",
		}),
		create_element("TextLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			FontFace = FONTS.regular,
			ZIndex = 3,
			Text = tostring(math.ceil(props.fill_value)),
			TextScaled = true,
			TextColor3 = COLOURS.white,
		}),
		create_element(
			"Frame",
			{
				BackgroundColor3 = COLOURS.white,
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.fromScale(0, 0.5),
				Size = UDim2.fromScale(props.fill_value / props.fill_total, 1),
				ZIndex = 2,
			},
			create_element("UIGradient", {
				Color = props.colour_gradient,
			}),
			create_element("UICorner", {
				CornerRadius = UDim.new(0.45, 0),
			})
		)
	)
end

type state_setter<T> = (((T) -> T) | T) -> ()
local function use_character(): Model?
	local character: Model?, set_character: state_setter<Model?> = use_state(local_player.Character)

	local function effect_character_formation()
		local function on_character_added(character: Model): ()
			set_character(character)
		end

		local connection_character_added = local_player.CharacterAdded:Connect(on_character_added)

		local function on_character_removing(): ()
			set_character(nil)
		end

		local connection_character_removing = local_player.CharacterRemoving:Connect(on_character_removing)
		set_character(local_player.Character)

		local function disconnect(): ()
			connection_character_added:Disconnect()
			connection_character_removing:Disconnect()
		end

		return disconnect
	end

	use_effect(effect_character_formation, {})

	local function effect_character_destroying()
		local connection_character_destroying: RBXScriptConnection?
		if character ~= nil then
			local function on_character_destroying(): ()
				local function clear_if_current(current: Model?): Model?
					return if current == character then nil else current
				end
				set_character(clear_if_current)
			end

			connection_character_destroying = character.Destroying:Connect(on_character_destroying)
		else
			connection_character_destroying = nil
		end

		local function disconnect()
			if connection_character_destroying ~= nil then
				connection_character_destroying:Disconnect()
			end
		end

		return disconnect
	end

	use_effect(effect_character_destroying, { character })

	return character
end

local function use_humanoid(): Humanoid?
	local character = use_character()
	local humanoid: Humanoid?, set_humanoid: state_setter<Humanoid?> =
		use_state(if character then character:FindFirstChildOfClass("Humanoid") else nil)

	local function effect_humanoid()
		if character == nil then
			set_humanoid(nil)
			return
		end

		local function update_humanoid(): ()
			set_humanoid(character:FindFirstChildOfClass("Humanoid"))
		end

		local function on_child_changed(child: Instance): ()
			if child:IsA("Humanoid") then
				update_humanoid()
			end
		end

		local connection_child_added = character.ChildAdded:Connect(on_child_changed)
		local connection_child_removed = character.ChildRemoved:Connect(on_child_changed)
		update_humanoid()

		local function disconnect(): ()
			connection_child_added:Disconnect()
			connection_child_removed:Disconnect()
		end

		return disconnect
	end

	use_effect(effect_humanoid, { character })

	return humanoid
end

local function get_health_optional(humanoid: Humanoid?): number
	if humanoid == nil then
		return 0
	end

	return humanoid.Health
end

local function use_health_main(): number
	local humanoid = use_humanoid()
	local health_main, set_health_main = use_state(get_health_optional(humanoid))

	local function effect_health_main()
		if humanoid == nil then
			set_health_main(0)
			return
		end

		set_health_main(humanoid.Health)

		local function on_health_changed(health: number): ()
			set_health_main(health)
		end

		local connection = humanoid.HealthChanged:Connect(on_health_changed)

		local function disconnect(): ()
			connection:Disconnect()
		end

		return disconnect
	end

	use_effect(effect_health_main, { humanoid })

	return health_main
end

local function health_main()
	local health_main = use_health_main()

	local props_slider = {
		anchor_point = Vector2.zero,
		colour_background = COLOURS.red_900,
		colour_gradient = ColorSequence.new({
			ColorSequenceKeypoint.new(0, COLOURS.red_700),
			ColorSequenceKeypoint.new(1, COLOURS.red_800),
		}),
		colour_stroke = COLOURS.red_900,
		fill_total = 100,
		fill_value = health_main,
		name = "health_main",
		position = UDim2.fromOffset(0, 0),
		size = UDim2.fromScale(1, 1),
	}

	return create_element(slider_display, props_slider)
end

local function health_shield(props: {
	health_shield: number,
})
	local props_slider = {
		anchor_point = Vector2.new(0, 1),
		colour_background = COLOURS.sky_800,
		colour_gradient = ColorSequence.new({
			ColorSequenceKeypoint.new(0, COLOURS.sky_600),
			ColorSequenceKeypoint.new(1, COLOURS.sky_700),
		}),
		colour_stroke = COLOURS.sky_800,
		fill_total = 20,
		fill_value = props.health_shield,
		name = "health_shield",
		-- sits above the main bar, outside of the layout
		position = UDim2.fromOffset(0, -10),
		size = UDim2.new(0.4, 0, 1, 0),
	}

	return create_element(slider_display, props_slider)
end

local function health_bar(props: {
	health_shield: number,
})
	return create_element("Frame", {
		Name = "health_bar",
		BackgroundTransparency = 1,
		LayoutOrder = 0,
		Size = UDim2.fromOffset(HEALTH_WIDTH, HEALTH_HEIGHT),
	}, create_element(health_main), props.health_shield > 0 and create_element(health_shield, {
		health_shield = props.health_shield,
	}))
end

local function use_active_slot(): number
	local active_slot, set_active_slot = use_state(tool_state.current)

	local function effect_active_slot()
		local function on_fire(slot: number): ()
			set_active_slot(slot)
		end

		local connection = tool_state.on_change:Connect(on_fire)

		local function disconnect(): ()
			connection:Disconnect()
		end

		return disconnect
	end

	use_effect(effect_active_slot, {})

	return active_slot
end

local function select_slot(slot: number): ()
	tool_state.on_select_requested:Fire(slot)
end

-- One click handler per slot, made once so slots do not render again for a new function every time.
local on_clicks: { () -> () } = {}
for slot = 1, INVENTORY_CONSTANTS.COLUMNS do
	local function on_click(): ()
		select_slot(slot)
	end
	on_clicks[slot] = on_click
end

local function slots_container(props: { preview: boolean? })
	local active_slot = use_active_slot()
	use_inventory_version()

	local slots = {}
	for id = 1, INVENTORY_CONSTANTS.COLUMNS do
		const tool = get_slot_tool(id)
		slots[id] = create_element(item_slot, {
			name = `slot_{id}`,
			image = if tool ~= nil then tool.image else nil,
			layout_order = id,
			selected = id == active_slot,
			on_click = if props.preview then nil else on_clicks[id],
		})
	end

	-- a fixed size, since a grid inside an automatically sized frame wraps at whatever width it guesses
	return create_element("Frame", {
		BackgroundColor3 = COLOURS.surface,
		BackgroundTransparency = 0.5,
		LayoutOrder = 1,
		Name = "slots_container",
		Size = UDim2.fromOffset(SLOTS_WIDTH, SLOTS_HEIGHT),
	}, {
		corner = create_element("UICorner", { CornerRadius = UDim.new(0.45, 0) }),
		blur = not props.preview and create_element(ui_blur),
		grid = create_element("UIGridLayout", {
			CellPadding = UDim2.fromOffset(INVENTORY_LAYOUT.HOTBAR_SLOT_GAP, INVENTORY_LAYOUT.HOTBAR_SLOT_GAP),
			CellSize = UDim2.fromOffset(INVENTORY_LAYOUT.SLOT_SIZE, INVENTORY_LAYOUT.SLOT_SIZE),
			FillDirectionMaxCells = INVENTORY_CONSTANTS.COLUMNS,
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
		padding = create_element("UIPadding", {
			PaddingBottom = UDim.new(0, INVENTORY_LAYOUT.HOTBAR_PADDING),
			PaddingLeft = UDim.new(0, INVENTORY_LAYOUT.HOTBAR_PADDING),
			PaddingRight = UDim.new(0, INVENTORY_LAYOUT.HOTBAR_PADDING),
			PaddingTop = UDim.new(0, INVENTORY_LAYOUT.HOTBAR_PADDING),
		}),
		shadow = create_element(shadow, { ShowBehindParent = false, BlurRadius = UDim.new(0, 8), Transparency = 0.3 }),
		stroke = create_element(gradient_stroke),
		slots = create_element(React.Fragment, {}, slots),
	})
end

-- The inventory window has its own hotbar row, so this one hides while it is open.
local function use_inventory_open(): boolean
	local open, set_open = use_state(inventory_state.enabled)

	local function subscribe()
		local function on_change(): ()
			set_open(inventory_state.enabled)
		end

		local connection = inventory_state.on_change:Connect(on_change)

		local function disconnect(): ()
			connection:Disconnect()
		end

		return disconnect
	end

	use_effect(subscribe, {})

	return open
end

local function hotbar(props: use_editable_hud.props)
	local content_ref = use_editable_hud(hotbar, props)
	local inventory_open = use_inventory_open()
	return create_element(
		hud_screen,
		{
			Enabled = not inventory_open,
			Name = "Hotbar",
			preview = props.preview,
			ResetOnSpawn = false,
		},
		create_element("Frame", {
			ref = content_ref,
			AnchorPoint = if props.preview then Vector2.new(0.5, 0.5) else Vector2.new(0.5, 1),
			AutomaticSize = Enum.AutomaticSize.XY,
			BackgroundTransparency = 1,
			Position = if props.preview then UDim2.fromOffset(0, 0) else UDim2.new(0.5, 0, 1, -20),
			Size = UDim2.fromOffset(0, 0),
		}, {
			layout = create_element("UIListLayout", {
				FillDirection = Enum.FillDirection.Vertical,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				Padding = UDim.new(0, 10),
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),
			scale = create_element(scale),
			health_bar = create_element(health_bar, {
				health_shield = 0,
			}),
			slots_container = create_element(slots_container, { preview = props.preview }),
		})
	)
end

return hotbar
