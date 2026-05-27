local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local React = require(ReplicatedStorage.Packages.react)
local ReactRoblox = require(ReplicatedStorage.Packages["react-roblox"])
local team_mod = require(ReplicatedStorage.shared.team)

local create_element = React.createElement
type team = team_mod.team
local use_effect = React.useEffect
local use_state = React.useState

local colours = require(ReplicatedStorage.shared.ui.colours)

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

local colour_green = "#5bd34c"

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

		-- It is good to have the parameter of how many kills to add since some actions, such as explosions, may damage many people, resulting in multiple kills in one moment.
		local function on_event(added_kills: number): ()
			local function updater(kills: number): number
				return kills + added_kills
			end
			set_kills(updater)
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

local function use_teams(): {team}
	local teams, set_teams = use_state(team_mod.all_teams)

	local function effect_teams()
		local function on_event(): ()
			set_teams(team_mod.all_teams)
		end

		local connection = team_mod.on_any_team_changed:Connect(on_event)

		local function destroy(): ()
			connection:Disconnect()
		end

		return destroy
	end

	use_effect(effect_teams, {})

	return teams
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
	local teams = use_teams()
	local time_elapsed = use_time_elapsed()

	local points_display_elements = {}
	for index, team in teams do
		local props_point_display: props_points_display = {
			colour = "#" .. team.colour:ToHex(),
			layout_order = index,
			name = `points of team "{team.name}"`,
			points = team.points,
			text_alignment_c1 = if index % 2 == 0 then "Right" else "Left",
		}
		local element = create_element(point_display, props_point_display)
		points_display_elements[index] = element
	end

	local minutes = time_elapsed // 60
	local seconds = time_elapsed - minutes*60
	local time_string = string.format("%02d:%02d", minutes, seconds)

	return create_element("ScreenGui", {
		ClipToDeviceSafeArea = false,
		Enabled = game_is_active,
		Name = "infoboard",
		ResetOnSpawn = false,
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
			points_display_elements,
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
