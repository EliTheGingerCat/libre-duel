local ReplicatedStorage = game:GetService("ReplicatedStorage")

const FONTS = require(ReplicatedStorage.shared.ui.FONTS)
local React = require(ReplicatedStorage.Packages.react)
local about = require(script.Parent.about)
local menu_window = require(script.Parent.Parent.visuals.menu_window)
local scrolling_content = require(script.Parent.Parent.visuals.scrolling_content)
local setting_row = require(script.Parent.setting_row)
local settings_registry = require(script.Parent.settings_registry)
local sidebar = require(script.Parent.sidebar)

local function increment(value: number): number
	return value + 1
end

local function settings_menu(props: { enabled: boolean, on_close: () -> () })
	local selected, set_selected = React.useState("interface")
	local query, set_query = React.useState("")
	local _, set_revision = React.useState(0)
	local function subscribe()
		local function update(): ()
			set_revision(increment)
		end
		return settings_registry.subscribe(update)
	end
	React.useEffect(subscribe, {})
	local function choose(category: string): ()
		set_selected(category)
		set_query("")
	end
	local children = {
		layout = React.createElement(
			"UIListLayout",
			{ Padding = UDim.new(0, 20), SortOrder = Enum.SortOrder.LayoutOrder }
		),
		padding = React.createElement("UIPadding", {
			PaddingTop = UDim.new(0, 12),
			PaddingBottom = UDim.new(0, 32),
			PaddingLeft = UDim.new(0, 48),
			PaddingRight = UDim.new(0, 48),
		}),
	}
	local count = 0
	local search = query:lower()
	for index, entry in settings_registry.entries do
		if
			settings_registry.is_visible(entry)
			and (
				(search == "" and entry.category == selected)
				or (search ~= "" and string.find(entry.text:lower(), search, 1, true))
			)
		then
			count += 1
			children[entry.id] = React.createElement(setting_row, { entry = entry, order = index })
		end
	end
	if selected == "about" and search == "" then
		children.about = React.createElement(about)
	elseif count == 0 then
		children.empty = React.createElement("TextLabel", {
			Size = UDim2.new(1, 0, 0, 64),
			BackgroundTransparency = 1,
			Text = if search ~= "" then "No settings found." else "No settings here yet.",
			TextSize = 30,
			TextColor3 = Color3.new(1, 1, 1),
			FontFace = FONTS.regular,
		})
	end
	return React.createElement(menu_window, {
		name = "Settings",
		title = "Settings",
		size = Vector2.new(1200, 720),
		enabled = props.enabled,
		on_close = props.on_close,
	}, props.enabled and {
		sidebar = React.createElement(
			sidebar,
			{ selected = selected, query = query, on_selected = choose, on_search = set_query }
		),
		content = React.createElement(scrolling_content, {
			position = UDim2.new(0.28, 0, 0, 76),
			size = UDim2.new(0.72, -12, 1, -96),
			reset_key = selected .. query,
		}, children),
	})
end

return settings_menu
