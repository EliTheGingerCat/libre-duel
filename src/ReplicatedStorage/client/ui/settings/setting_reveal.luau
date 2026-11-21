local ReplicatedStorage = game:GetService("ReplicatedStorage")

const React = require(ReplicatedStorage.Packages.react)
const collapsible_reveal = require(script.Parent.Parent.effects.collapsible_reveal)
const setting_row = require(script.Parent.setting_row)
const settings_registry = require(script.Parent.settings_registry)

const create_element = React.createElement
-- part of each row instead of a list layout's padding, so the gap collapses with the row
const ROW_GAP = 20
const NESTED_GAP = 8

const function setting_reveal(props: {
	entry: settings_registry.entry,
	order: number,
	shown: boolean,
	nested: boolean?,
})
	local nested_rows = nil
	for index, child in settings_registry.get_children(props.entry.id) do
		nested_rows = nested_rows or {}
		nested_rows[child.id] = create_element(
			setting_reveal,
			{ entry = child, order = index, shown = settings_registry.is_visible(child), nested = true }
		)
	end
	return create_element(collapsible_reveal, {
		shown = props.shown,
		name = props.entry.id,
		layout_order = props.order,
		gap = if props.nested then NESTED_GAP else ROW_GAP,
		top_offset = if props.nested then NESTED_GAP else 0,
		fade = props.entry.visible ~= nil,
	}, {
		row = create_element(setting_row, { entry = props.entry, order = props.order, children = nested_rows }),
	})
end

return setting_reveal
