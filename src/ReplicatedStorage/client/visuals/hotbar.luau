local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.react)
local ReactRoblox = require(ReplicatedStorage.Packages["react-roblox"])
local scale = require(script.Parent.scale)
local tool_state = require(script.Parent.Parent.modules.ui.tool_state)
local tools = require(script.Parent.Parent.modules.ui.tools)

local colours = require(ReplicatedStorage.modules.ui.colours)
local create_element = React.createElement
local local_player = Players.LocalPlayer
local use_effect = React.useEffect
local use_state = React.useState

local function slider_display(props: {
	colour_background: Color3,
	colour_gradient: ColorSequence,
	colour_stroke: Color3,
	fill_total: number,
	fill_value: number,
	name: string,
	position_y_offset: number,
	size_x_scale: number,
})
	return create_element("Frame", {
		AnchorPoint = Vector2.new(0, 1),
		BackgroundColor3 = props.colour_background,
		Name = props.name,
		Position = UDim2.fromOffset(10, props.position_y_offset),
		Size = UDim2.new(props.size_x_scale, -20, 0, 26),
	},
		create_element("UICorner", {
			CornerRadius = UDim.new(0.45, 0),
		}),
		create_element("UIStroke", {
			Thickness = 2,
			Color = props.colour_stroke,
			ApplyStrokeMode = "Border",
		}),
		create_element("TextLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			FontFace = Font.fromId(11702779409, Enum.FontWeight.Regular),
			ZIndex = 3,
			Text = tostring(math.ceil(props.fill_value)),
			TextScaled = true,
			TextColor3 = colours.white,
		}),
		create_element("Frame", {
			BackgroundColor3 = colours.white,
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.fromScale(0, 0.5),
			Size = UDim2.fromScale(props.fill_value / props.fill_total, 1),
			ZIndex = 2,
		},
			create_element("UIGradient", {
				Color = props.colour_gradient,
			}),
			create_element("UICorner", {
				CornerRadius = UDim.new(0.45, 0)
			})
		)
	)
end

local function use_character(): Model?
	local character, set_character = use_state(local_player.Character)

	local function effect_character_formation()
		local function on_character_added(character: Model): ()
			set_character(character)
		end

		local connection_character_added = local_player.CharacterAdded:Connect(on_character_added)

		local function on_character_removing(): ()
			set_character(nil)
		end

		local connection_character_removing = local_player.CharacterRemoving:Connect(on_character_removing)

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
				set_character(nil)
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

	use_effect(effect_character_destroying, {character})

	return character
end

local function use_humanoid(): Humanoid?
	local character = use_character()

	if character == nil then
		return nil
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
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

	use_effect(effect_health_main, {humanoid})

	return health_main
end

local function health_main()
	local health_main = use_health_main()

	local props_slider = {
		colour_background = colours.red_900,
		colour_gradient = ColorSequence.new({
			ColorSequenceKeypoint.new(0, colours.red_700),
			ColorSequenceKeypoint.new(1, colours.red_800),
		}),
		colour_stroke = colours.red_900,
		fill_total = 100,
		fill_value = health_main,
		name = "health_main",
		position_y_offset = -10,
		size_x_scale = 1,
	}

	return create_element(slider_display, props_slider)
end

local function health_shield(props: {
	health_shield: number
})
	local props_slider = {
		colour_background = colours.sky_800,
		colour_gradient = ColorSequence.new({
			ColorSequenceKeypoint.new(0, colours.sky_600),
			ColorSequenceKeypoint.new(1, colours.sky_700),
		}),
		colour_stroke = colours.sky_800,
		fill_total = 20,
		fill_value = props.health_shield,
		name = "health_shield",
		position_y_offset = -46,
		size_x_scale = 0.4,
	}

	return create_element(slider_display, props_slider)
end

local function health_bar(props: {
	health_shield: number,
})
	return create_element("Frame", {
		Name = "health_bar",
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
	},
		create_element(health_main),
		props.health_shield > 0 and create_element(health_shield, {
			health_shield = props.health_shield
		})
	)
end

local function active_slot_addendum()
	return create_element("UIStroke", {
		Color = colours.white,
		Thickness = 2,
	},
		create_element("UIGradient", {
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, colours.light_grey),
				ColorSequenceKeypoint.new(1, colours.dark_grey),
			}),
			Rotation = -90,
		})
	)
end

local function slot(props: {
	active: boolean,
	id: number,
	text: string,
})
	return create_element("Frame", {
		BackgroundColor3 = colours.black,
		BackgroundTransparency = 0.8,
		Name = props.id,
		Size = UDim2.fromScale(1, 1),
		LayoutOrder = props.id,
	},
		create_element("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(0.8, 0.8),
			Text = props.text,
			TextColor3 = colours.white,
			TextScaled = true,
			TextSize = 20,
		}),
		create_element("UIAspectRatioConstraint"),
		create_element("UICorner", {
			CornerRadius = UDim.new(0.45, 0),
		}),
		props.active and active_slot_addendum()
	)
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

local function slots_container()
	local active_slot = use_active_slot()

	local slots = {}
	for id = 1, 9 do
		slots[id] = create_element(slot, {
			active = id == active_slot,
			id = id,
			text = tools[id] :: string or "",
		})
	end

	return create_element("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Name = "slots_container",
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.new(1, -10, 1, -10),
	},
		create_element("UIListLayout", {
			Padding = UDim.new(0, 5),
			FillDirection = "Horizontal",
			HorizontalAlignment = "Center",
			SortOrder = "LayoutOrder",
		}),
		slots
	)
end

local function hotbar()
	return create_element("ScreenGui", {
		Name = "Hotbar",
		ResetOnSpawn = false,
	},
		create_element("Frame", {
				AnchorPoint = Vector2.new(0.5, 1),
				BackgroundColor3 = colours.black,
				BackgroundTransparency = 0.5,
				Position = UDim2.new(0.5, 0, 1, -10),
				Size = UDim2.fromOffset(680, 80),
			},
			create_element("UICorner", {
				CornerRadius = UDim.new(0.45, 0),
			}),
			create_element("UIStroke", {
				Color = colours.white,
				Thickness = 2,
			},
				create_element("UIGradient", {
					Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, colours.light_grey),
						ColorSequenceKeypoint.new(1, colours.dark_grey),
					}),
					Rotation = -90,
				})
			),
			create_element(scale),
			create_element(health_bar, {
				health_shield = 0,
			}),
			create_element(slots_container)
		)
	)
end

return hotbar
