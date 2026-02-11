local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local get_perceived_lightness = require(ReplicatedStorage.modules.get_perceived_lightness)
local keybinds = require(ReplicatedStorage.client.modules.keybinds)
local location_default = require(ReplicatedStorage.modules.location_default)
local React = require(ReplicatedStorage.vendor.ReactLua.React)
local scale = require(script.Parent.scale)

local create_element = React.createElement
local local_player = Players.LocalPlayer
local use_effect = React.useEffect
local use_state = React.useState

local function title()
	return create_element("TextLabel", {
		AnchorPoint = Vector2.new(0.5, 1),
		Size = UDim2.new(1, 0, 0, 40),
		Position = UDim2.fromScale(0.5, 0),
		FontFace = Font.fromId(11702779409, Enum.FontWeight.Regular),
		BackgroundTransparency = 1,
		TextSize = 40,
		RichText = true,
		TextYAlignment = "Top",
		Text = '<font color="#b14c4e">Libre</font> <font color="#0da2dd">Duel</font>',
	})
end

local function player_card(props: {
	colour: Color3,
	image: string,
	name: string,
	order: number,
})
	return create_element("TextLabel", {
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
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
			CornerRadius = UDim.new(0, 50),
		}),
		create_element("UIStroke", {
			Color = Color3.fromRGB(255, 255, 255),
			ApplyStrokeMode = "Border",
			Thickness = 2,
		},
			create_element("UIGradient", {
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, props.colour),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(70, 70, 70)),
				}),
				Rotation = -90,
			})
		),
		create_element("ImageLabel", {
			Position = UDim2.fromOffset(-40, 0),
			BackgroundTransparency = 1,
			Size = UDim2.fromOffset(38, 38),
			Image = props.image,
		},
			create_element("UICorner", {
				CornerRadius = UDim.new(1, 0),
			})
		)
	)
end

local function use_players(): {Player}
	local players, set_players = use_state(Players:GetPlayers())

	use_effect(function()
		local function on_player_list_change(player: Player): ()
			set_players(Players:GetPlayers())
		end

		local connection_added = Players.PlayerAdded:Connect(on_player_list_change)
		local connection_removed = Players.PlayerRemoving:Connect(on_player_list_change)

		local function destroy()
			connection_added:Disconnect()
			connection_removed:Disconnect()
		end
		
		return destroy
	end, {})

	return players
end

local function player_list()
	local players = use_players()

	local cards = {}
	for index, player in players do
		cards[index] = create_element(player_card, {
			key = player.UserId,
			colour = player.TeamColor.Color,
			image = `rbxthumb://type=AvatarBust&id={player.UserId}&w=50&h=50`,
			name = player.Name,
			order = get_perceived_lightness(player.TeamColor.Color) * -10000, --multiplying because the LayoutOrder property automatically rounds off decimals and i want accuracy.
		})
	end

	return create_element("Folder", {},
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

	return create_element("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromScale(0.5, 1),
		FontFace = Font.fromId(11702779409, Enum.FontWeight.Regular),
		TextColor3 = Color3.fromRGB(133, 221, 50),
		TextSize = 40,
		Size = UDim2.new(0.5, 0, 0, 40),
		Text = `Ping: {math.round(ping * 1000)} ms`,
	})
end

local location_saved = location_default
local function use_location(): location_default.location
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
		Position = UDim2.fromScale(0, 1),
		FontFace = Font.fromId(11702779409, Enum.FontWeight.Regular),
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextSize = 40,
		Size = UDim2.new(0.5, 0, 0, 40),
		Text = location_text,
	})
end

-- `key` must be constant.
local function use_if_key_held(key: Enum.KeyCode): boolean
	local held, set_held = use_state(UserInputService:IsKeyDown(key))

	use_effect(function()
		local function on_input_began(input: InputObject): ()
			if input.KeyCode == key then
				set_held(true)
			end
		end

		local connection_began = UserInputService.InputBegan:Connect(on_input_began)

		local function on_input_ended(input: InputObject): ()
			if input.KeyCode == key then
				set_held(false)
			end
		end

		local connection_ended = UserInputService.InputEnded:Connect(on_input_ended)

		local function destroy()
			connection_began:Disconnect()
			connection_ended:Disconnect()
		end

		return destroy
	end, {}) -- Zero dependencies since `key` is constant.

	return held
end

local function tablist()
	local enabled = use_if_key_held(keybinds.tablist)

	return create_element("ScreenGui", {
		Enabled = enabled,
		Name = "Tablist",
		ResetOnSpawn = false,
	},
		create_element("Frame", {
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.new(0.5, 0, 0, 147),
			Size = UDim2.fromOffset(720, 0),
			AutomaticSize = "Y",
			BackgroundColor3 = Color3.fromRGB(0, 0, 0),
			BackgroundTransparency = 0.5,
		},
			create_element("UICorner", {
				CornerRadius = UDim.new(0, 30),
			}),
			create_element("UIPadding", {
				PaddingBottom = UDim.new(0, 40),
				PaddingLeft = UDim.new(0, 10),
				PaddingRight = UDim.new(0, 10),
				PaddingTop = UDim.new(0, 40),
			}),
			create_element("UIStroke", {
				Thickness = 2,
				Color = Color3.fromRGB(255, 255, 255),
				ApplyStrokeMode = "Border",
			},
				create_element("UIGradient", {
					Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.fromRGB(134, 134, 134)),
						ColorSequenceKeypoint.new(1, Color3.fromRGB(70, 70, 70)),
					}),
					Rotation = -90,
				})
			),
			create_element(scale),
			create_element(title),
			create_element(player_list),
			create_element(location_display),
			create_element(ping_display)
		)
	)
end

return tablist
