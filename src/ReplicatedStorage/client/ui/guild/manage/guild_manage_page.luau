const ReplicatedStorage = game:GetService("ReplicatedStorage")

const COLOURS = require(ReplicatedStorage.shared.ui.COLOURS)
const React = require(ReplicatedStorage.Packages.react)
const button = require(script.Parent.Parent.Parent.visuals.button)
const section_card = require(script.Parent.Parent.Parent.profile_card.section_card)

const create_element = React.createElement

const function guild_manage_page(props: { on_delete_guild: () -> () })
	return create_element(section_card, {
		name = "danger_zone",
		title = "Danger zone",
		title_colour = COLOURS.danger_text,
		layout_order = 1,
		padding_bottom = 30,
	}, {
		delete_guild = create_element("Frame", {
			LayoutOrder = 1,
			Size = UDim2.fromOffset(200, 50),
			AutomaticSize = Enum.AutomaticSize.X,
			BackgroundTransparency = 1,
		}, {
			button = create_element(button, {
				danger = true,
				text = "Delete guild",
				on_activated = props.on_delete_guild,
			}),
		}),
	})
end

return guild_manage_page
