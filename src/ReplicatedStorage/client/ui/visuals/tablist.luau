local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

const COLOURS = require(ReplicatedStorage.shared.ui.COLOURS)
local get_perceived_lightness = require(ReplicatedStorage.shared.ui.get_perceived_lightness)
const KEYBINDS = require(ReplicatedStorage.client.util.KEYBINDS)
const LOCATION_DEFAULT = require(ReplicatedStorage.shared.ui.LOCATION_DEFAULT)
local React = require(ReplicatedStorage.Packages.react)
const registry = require(ReplicatedStorage.shared.entity.registry)
local scale = require(script.Parent.scale)
local use_editable_hud = require(script.Parent.Parent.hud.use_editable_hud)
local use_if_key_held = require(script.Parent.use_if_key_held)

local create_element = React.createElement
local local_player = Players.LocalPlayer
local use_effect = React.useEffect
local use_state = React.useState

local function entity_card(props: {
	colour: Color3,
	image: string,
	name: string,
	order: number,
})
	return create_element(
		"TextLabel",
		{
			BackgroundColor3 = COLOURS.black,
			BackgroundTransparency = 0.7,
			FontFace = Font.fromId(11702779409, Enum.FontWeight.Regular),
			LayoutOrder = props.order,
			TextColor3 = props.colour,
			TextScaled = true,
			Size = UDim2.new(0.5, -5, 0, 38),
			TextXAlignment = "Left",
			Text = props.name,
		},
		create_element("UIPadding", {
			PaddingLeft = UDim.new(0, 40),
			PaddingRight = UDim.new(0, 5),
		}),
		create_element("UICorner", {
			CornerRadius = UDim.new(0.5, 0),
		}),
		create_element(
			"UIStroke",
			{
				Color = COLOURS.white,
				ApplyStrokeMode = "Border",
				Thickness = 2,
			},
			create_element("UIGradient", {
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, props.colour),
					ColorSequenceKeypoint.new(1, COLOURS.dark_grey),
				}),
				Rotation = -90,
			})
		),
		create_element(
			"ImageLabel",
			{
				Position = UDim2.fromOffset(-40, 0),
				BackgroundTransparency = 1,
				Size = UDim2.fromOffset(38, 38),
				Image = props.image,
			},
			create_element("UICorner", {
				CornerRadius = UDim.new(0.5, 0),
			})
		)
	)
end

local function use_entities(): { registry.entity }
	const entities, set_entities = use_state(registry.get_all())

	local function subscribe_to_entities()
		local function on_entity_list_change(): ()
			set_entities(registry.get_all())
		end
		const connection = registry.changed:Connect(on_entity_list_change)
		on_entity_list_change()
		local function destroy(): ()
			connection:Disconnect()
		end
		return destroy
	end
	use_effect(subscribe_to_entities, {})
	return entities
end

local function entity_list()
	const entities = use_entities()

	local cards = {}
	for index, entity in entities do
		const team = registry.get_team(entity)
		const colour = if team then team.TeamColor.Color else COLOURS.white
		const image = if type(entity) == "string" then "" else `rbxthumb://type=AvatarBust&id={entity.UserId}&w=50&h=50`
		const key = if type(entity) == "string" then `bot:{entity}` else `player:{entity.UserId}`
		cards[index] = create_element(entity_card, {
			key = key,
			colour = colour,
			image = image,
			name = registry.get_name(entity),
			order = get_perceived_lightness(colour) * -10000,
		})
	end

	return create_element(
		"Folder",
		{},
		create_element("UIListLayout", {
			Padding = UDim.new(0, 10),
			FillDirection = "Horizontal",
			SortOrder = "LayoutOrder",
			Wraps = true,
		}),
		cards
	)
end

local function use_ping(): number
	local ping, set_ping = use_state(0)

	use_effect(function()
		local function on_heartbeat()
			set_ping(local_player:GetNetworkPing())
		end

		local connection = RunService.Heartbeat:Connect(on_heartbeat)

		local function destroy()
			connection:Disconnect()
		end

		return destroy
	end, {})

	return ping
end

local function ping_display()
	local ping = use_ping()
	const IDEAL_PING, BAD_PING = 40, 350

	local progress = math.clamp((ping - IDEAL_PING) / (BAD_PING - IDEAL_PING), 0, 1)
	local hue = (1 / 3) * (1 - progress)
	local colour = Color3.fromHSV(hue, 0.61, 0.9) -- This does not use the colours modulescript but I am not sure how to make it.
	local hex = "#" .. colour:ToHex()

	local rich_text = string.format('<font color="%s">%d</font> ms', hex, math.round(ping))

	return create_element("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0.5, 0, 1, 2), --extra 2 offset because the text feels too high up otherwise..
		FontFace = Font.fromId(11702779409, Enum.FontWeight.Regular),
		TextColor3 = COLOURS.light_grey,
		TextSize = 36,
		Size = UDim2.new(0.5, 0, 0, 40),
		Text = "Ping: " .. rich_text,
		RichText = true,
	})
end

local location_saved = LOCATION_DEFAULT
local function use_location(): LOCATION_DEFAULT.location
	local location, set_location = use_state(location_saved)

	use_effect(function()
		if location_saved.status == "loading" then
			-- I know this is a side effect but Womp womp.
			location_saved = ReplicatedStorage.remotes.server_location:InvokeServer()
			set_location(location_saved)
		end
	end)

	return location
end

local function location_display()
	local location = use_location()

	local location_text: string
	if location.status == "loading" then
		location_text = "Server location is loading."
	elseif location.status == "fail" then
		location_text = "Failed to fetch server location."
	elseif location.status == "success" then
		location_text = location.result
	end

	return create_element("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 1, 2), --extra 2 offset because the text feels too high up otherwise..
		FontFace = Font.fromId(11702779409, Enum.FontWeight.Regular),
		TextColor3 = COLOURS.light_grey,
		TextSize = 36,
		Size = UDim2.new(0.5, 0, 0, 40),
		Text = location_text,
	})
end

local function tablist()
	local content_ref = use_editable_hud()
	local enabled = use_if_key_held(KEYBINDS.tablist)

	return create_element(
		"ScreenGui",
		{
			Enabled = enabled,
			Name = "Tablist",
			ResetOnSpawn = false,
		},
		create_element(
			"Frame",
			{
				ref = content_ref,
				AnchorPoint = Vector2.new(0.5, 0),
				Position = UDim2.new(0.5, 0, 0, 147),
				Size = UDim2.fromOffset(720, 0),
				AutomaticSize = "Y",
				BackgroundColor3 = COLOURS.black,
				BackgroundTransparency = 0.5,
			},
			create_element("UICorner", {
				CornerRadius = UDim.new(0, 39),
			}),
			create_element("UIPadding", {
				PaddingBottom = UDim.new(0, 45),
				PaddingLeft = UDim.new(0, 20),
				PaddingRight = UDim.new(0, 20),
				PaddingTop = UDim.new(0, 20),
			}),
			create_element(
				"UIStroke",
				{
					Thickness = 2,
					Color = COLOURS.white,
					ApplyStrokeMode = "Border",
				},
				create_element("UIGradient", {
					Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, COLOURS.light_grey),
						ColorSequenceKeypoint.new(1, COLOURS.dark_grey),
					}),
					Rotation = -90,
				})
			),
			create_element(scale),
			create_element(entity_list),
			create_element(location_display),
			create_element(ping_display)
		)
	)
end

return tablist
