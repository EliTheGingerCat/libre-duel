const ReplicatedStorage = game:GetService("ReplicatedStorage")

const React = require(ReplicatedStorage.Packages.react)
const menu_sidebar = require(script.Parent.Parent.sidebar.menu_sidebar)
const settings_registry = require(script.Parent.settings_registry)
const text_input = require(script.Parent.Parent.visuals.text_input)

const function sidebar(
	props: { selected: string, query: string, on_selected: (string) -> (), on_search: (string) -> () }
)
	return React.createElement(menu_sidebar, {
		entries = settings_registry.categories,
		selected = props.selected,
		on_selected = props.on_selected,
		header_height = 50,
		header = {
			input = React.createElement(text_input, {
				text = props.query,
				placeholder = "Search...",
				icon = "rbxassetid://113215135352721",
				on_changed = props.on_search,
			}),
		},
	})
end

return sidebar
