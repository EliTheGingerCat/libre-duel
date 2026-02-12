local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local React = require(ReplicatedStorage.vendor.ReactLua.React)

local create_element = React.createElement
local use_effect = React.useEffect
local use_state = React.useState

type TextXAlignment = "Center" | "Left" | "Right"

type props_text_label = {
	layout_order: number,
	name: string,
	text: string,
	text_alignment_c1: TextXAlignment,
	text_size: number,
}
local function text_label(props: props_text_label)
	return create_element("TextLabel", {
		BackgroundTransparency = 1,
		FontFace = Font.fromId(11702779409, Enum.FontWeight.Regular),
		LayoutOrder = props.layout_order,
		Name = props.name,
		RichText = true,
		TextSize = props.text_size,
		AutomaticSize = "XY",
		TextXAlignment = props.text_alignment_c1,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		Text = props.text,
	})
end

type props_points_display = {
	colour: string,
	layout_order: number,
	name: string,
	points: number,
	text_alignment_c1: TextXAlignment,
}
local function point_display(props: props_points_display)
	local points_full = string.rep("●", props.points)
	local points_empty = string.rep("○", 5 - props.points)

	local text: string
	if props.text_alignment_c1 == "Left" then
		text = `<font color="{props.colour}">{points_full}</font>{points_empty}`
	elseif props.text_alignment_c1 == "Right" then
		text = `{points_empty}<font color="{props.colour}">{points_full}</font>`
	else
		print("Invalid text alignment.")
		return create_element("Frame")
	end

	return create_element(text_label, {
		layout_order = props.layout_order,
		name = props.name,
		text = text,
		text_alignment_c1 = props.text_alignment_c1,
		text_size = 50,
	})
end

local colour_blue = "#0da2dd"
local colour_green = "#5bd34c"
local colour_red = "#b14c4e"

local function use_game_is_active(): boolean
	local game_is_active, set_game_is_active = use_state(false)

	local function effect_game_is_active()
		local function on_event(incoming_game_is_active: boolean): ()
			set_game_is_active(incoming_game_is_active)
		end

		local connection = ReplicatedStorage.remotes.game_is_active.OnClientEvent:Connect(on_event)

		local function disconnect(): ()
			connection:Disconnect()
		end

		return disconnect
	end

	use_effect(effect_game_is_active, {})

	return game_is_active
end

local function use_kills(): number
	local kills, set_kills = use_state(0)

	local game_is_active = use_game_is_active()

	local function effect_kills()
		if game_is_active == true then
			-- Game just started.
			set_kills(0)
		end

		local function on_event(incoming_kills: number): ()
			set_kills(incoming_kills)
		end

		local connection = ReplicatedStorage.remotes.kills.OnClientEvent:Connect(on_event)

		local function disconnect(): ()
			connection:Disconnect()
		end

		return disconnect
	end

	use_effect(effect_kills, {game_is_active})

	return kills
end

local function use_map(): string
	local map, set_map = use_state("unknown")

	local function effect_map()
		local function on_event(incoming_map: string): ()
			set_map(incoming_map)
		end

		local connection = ReplicatedStorage.remotes.map_name.OnClientEvent:Connect(on_event)

		local function disconnect(): ()
			connection:Disconnect()
		end

		return disconnect
	end

	use_effect(effect_map, {})

	return map
end

local function use_points_self(): number
	local points_self, set_points_self = use_state(0)

	local game_is_active = use_game_is_active()

	local function effect_points_self()
		if game_is_active == true then
			-- Game just started.
			set_points_self(0)
		end

		local function on_event(): ()
			local function updater(points_self: number): number
				return points_self + 1
			end
			set_points_self(updater)
		end

		local connection = ReplicatedStorage.remotes.score_self.OnClientEvent:Connect(on_event)

		local function disconnect(): ()
			connection:Disconnect()
		end

		return disconnect
	end

	use_effect(effect_points_self, {game_is_active})

	return points_self
end

local function use_points_teams(): {number}
	local points_teams, set_points_teams = use_state({0, 0})

	local game_is_active = use_game_is_active()

	local function effect_points_teams()
		if game_is_active == true then
			-- Game just started.
			set_points_teams({0, 0})
		end

		local function on_event(team_number: number): ()
			local function updater(points_teams: {number}): {number}
				local clone = table.clone(points_teams)
				clone[team_number] += 1
				return clone
			end
			set_points_teams(updater)
		end

		local connection = ReplicatedStorage.remotes.score_team.OnClientEvent:Connect(on_event)

		local function disconnect(): ()
			connection:Disconnect()
		end

		return disconnect
	end

	use_effect(effect_points_teams, {game_is_active})

	return points_teams
end

local function use_time_elapsed(): number
	local time_elapsed, set_time_elapsed = use_state(0)

	local game_is_active = use_game_is_active()

	local function effect_time_elapsed()
		if game_is_active == true then
			-- Game just started.
			local time_start = os.time()
			set_time_elapsed(0)

			local function on_heartbeat(time_change: number): ()
				local function updater(): number
					local time_now = os.time()
					return time_now - time_start
				end
				set_time_elapsed(updater)
			end

			local connection = RunService.Heartbeat:Connect(on_heartbeat)

			local function disconnect(): ()
				connection:Disconnect()
			end

			return disconnect
		else
			local function disconnect(): ()
			end

			return disconnect
		end
	end

	use_effect(effect_time_elapsed, {game_is_active})

	return time_elapsed
end

local function infoboard()
	local game_is_active = use_game_is_active()
	local kills = use_kills()
	local map = use_map()
	local points_self = use_points_self()
	local points_teams = use_points_teams()
	local time_elapsed = use_time_elapsed()

	-- TODO: Get team colours from the server.
	-- TODO: Support an arbitrary amount of teams. This is already done on the server.
	local points_blue = points_teams[1]
	local points_red = points_teams[2]

	local minutes = time_elapsed // 60
	local seconds = time_elapsed - minutes*60
	local time_string = string.format("%02d:%02d", minutes, seconds)

	return create_element("ScreenGui", {
		ClipToDeviceSafeArea = false,
		Enabled = game_is_active,
		ScreenInsets = "None",
	},
		create_element("Frame", {
				AnchorPoint = Vector2.new(0.5, 0),
				Position = UDim2.new(0.5, 0, 0, 10),
				Size = UDim2.fromOffset(401, 127),
				BackgroundColor3 = Color3.fromRGB(0, 0, 0),
				BackgroundTransparency = 0.5,
		},
			create_element("UIGridLayout", {
				CellSize = UDim2.fromOffset(175, 32),
				FillDirection = "Horizontal",
				SortOrder = "LayoutOrder",
				HorizontalAlignment = "Center",
				CellPadding = UDim2.fromScale(0, 0),
			}),
			create_element("UIPadding", {
				PaddingBottom = UDim.new(0, 13),
				PaddingLeft = UDim.new(0, 15),
				PaddingRight = UDim.new(0, 15),
				PaddingTop = UDim.new(0, 15),
			}),
			create_element("UICorner", {
				CornerRadius = UDim.new(0.3, 0),
			}),
			create_element("UIStroke", {
				Thickness = 2,
				Color = Color3.fromRGB(255, 255, 255),
			},
				create_element("UIGradient", {
					Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromRGB(134, 134, 134)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(70, 70, 70)),
				}),
					Rotation = -90,
			})),
			create_element(point_display, {
				colour = colour_red,
				layout_order = 1,
				name = "points_red",
				points = points_red,
				text_alignment_c1 = "Left",
			}),
			create_element(point_display, {
				colour = colour_blue,
				layout_order = 2,
				name = "points_blue",
				points = points_blue,
				text_alignment_c1 = "Right",
			}),
			create_element(text_label, {
				layout_order = 3,
				name = "map",
				text = `<font color="{colour_green}">Map: </font>{map}`,
				text_alignment_c1 = "Left",
				text_size = 30,
			}),
			create_element(text_label, {
				layout_order = 4,
				name = "timer",
				text = `<font color="{colour_green}">Time: </font>{time_string}`,
				text_alignment_c1 = "Right",
				text_size = 30,
			}),
			create_element(text_label, {
				layout_order = 5,
				name = "kills",
				text = `<font color="{colour_green}">Kills: </font>{kills}`,
				text_alignment_c1 = "Left",
				text_size = 30,
			}),
			create_element(text_label, {
				layout_order = 6,
				name = "points_self",
				text = `<font color="{colour_green}">Goals: </font>{points_self}`,
				text_alignment_c1 = "Right",
				text_size = 30,
			})
		)
	)
end

return infoboard
