local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.react)
local menu_window = require(script.Parent.Parent.visuals.menu_window)
local registry = require(script.Parent.registry)
local scrolling_content = require(script.Parent.Parent.visuals.scrolling_content)
local selector_tile = require(script.Parent.selector_tile)

local create_element = React.createElement

const WIDGETS = {
	{ "Keystrokes", "Keystrokes" },
	{ "Mousestrokes", "Mousestrokes" },
	{ "FpsCounter", "FPS Counter" },
	{ "ReachCounter", "Reach Counter" },
	{ "ComboCounter", "Combo Counter" },
	{ "Paperdoll", "Paperdoll" },
	{ "Hotbar", "Hotbar" },
	{ "PlayButton", "Play Button" },
	{ "QueueStatus", "Queue Status" },
	{ "infoboard", "Infoboard" },
	{ "Notifications", "Notifications" },
	{ "Tablist", "Player List" },
}

local function increment(value: number): number
	return value + 1
end

local function selector(props: { enabled: boolean, display_order: number, on_close: () -> () })
	local _, set_revision = React.useState(0)
	local function subscribe()
		local function update(): ()
			set_revision(increment)
		end
		return registry.subscribe(update)
	end
	React.useEffect(subscribe, {})
	local tiles = {}
	if props.enabled then
		for index, widget in WIDGETS do
			for _, item in registry.get_entries() do
				if item.screen.Name == widget[1] then
					tiles[widget[1]] = create_element(
						selector_tile,
						{ item = item, title = widget[2], order = index, on_close = props.on_close }
					)
					break
				end
			end
		end
	end
	return create_element(
		menu_window,
		{
			name = "HudSelector",
			title = "Select HUD element",
			enabled = props.enabled,
			display_order = props.display_order,
			on_close = props.on_close,
		},
		create_element(scrolling_content, {
			anchor = Vector2.new(0.5, 1),
			position = UDim2.new(0.5, 0, 1, -20),
			size = UDim2.new(0.8, 0, 1, -76),
		}, {
			padding = create_element("UIPadding", {
				PaddingLeft = UDim.new(0, 40),
				PaddingRight = UDim.new(0, 40),
				PaddingTop = UDim.new(0, 20),
				PaddingBottom = UDim.new(0, 40),
			}),
			layout = create_element("UIGridLayout", {
				CellSize = UDim2.fromOffset(256, 256),
				CellPadding = UDim2.fromOffset(20, 20),
				SortOrder = Enum.SortOrder.LayoutOrder,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
			}),
			tiles = create_element(React.Fragment, {}, tiles),
		})
	)
end

return selector
