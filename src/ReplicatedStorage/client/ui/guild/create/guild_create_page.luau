const ReplicatedStorage = game:GetService("ReplicatedStorage")

const GUILD_LIMITS = require(ReplicatedStorage.shared.guild.GUILD_LIMITS)
const React = require(ReplicatedStorage.Packages.react)
const button = require(script.Parent.Parent.Parent.visuals.button)
const guild_snapshot_types = require(ReplicatedStorage.shared.guild.guild_snapshot_types)
const guild_text_field = require(script.Parent.guild_text_field)
const validate_guild_info = require(ReplicatedStorage.shared.guild.validate_guild_info)

const create_element = React.createElement

const CREATE_COLOUR = Color3.fromRGB(166, 255, 134)
const DESCRIPTION_HEIGHT = 192
const FORM_WIDTH = 0.6

const function guild_create_page(
	props: {
		-- true while the server is still working on the last request, so the button can't be spammed
		pending: boolean,
		on_create: (info: guild_snapshot_types.guild_info_input) -> (),
	}
)
	const name, set_name = React.useState("")
	const tag, set_tag = React.useState("")
	const description, set_description = React.useState("")
	const info: guild_snapshot_types.guild_info_input = {
		name = name,
		tag = tag,
		description = description,
		icon = "",
		banner = "",
		discord_invite = "",
	}
	const can_create = not props.pending and validate_guild_info(info) == nil
	const function create(): ()
		if can_create then
			props.on_create(info)
		end
	end
	return create_element("Frame", {
		Name = "create",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
	}, {
		form = create_element("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(FORM_WIDTH, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
		}, {
			layout = create_element("UIListLayout", {
				Padding = UDim.new(0, 10),
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),
			name = create_element(guild_text_field, {
				label = "Guild name",
				required = true,
				placeholder = "e.g. The Bridgers",
				text = name,
				max_length = GUILD_LIMITS.MAX_NAME_LENGTH,
				layout_order = 1,
				on_changed = set_name,
			}),
			tag = create_element(guild_text_field, {
				label = "Guild tag",
				required = true,
				placeholder = "e.g. BRIDGE",
				text = tag,
				max_length = GUILD_LIMITS.MAX_TAG_LENGTH,
				layout_order = 2,
				on_changed = set_tag,
			}),
			description = create_element(guild_text_field, {
				label = "Guild description",
				label_note = "(supports rich text)",
				placeholder = "Enter text...",
				text = description,
				max_length = GUILD_LIMITS.MAX_DESCRIPTION_LENGTH,
				multi_line = true,
				height = DESCRIPTION_HEIGHT,
				layout_order = 3,
				on_changed = set_description,
			}),
			create = create_element("Frame", {
				LayoutOrder = 4,
				Size = UDim2.fromOffset(200, 50),
				AutomaticSize = Enum.AutomaticSize.X,
				BackgroundTransparency = 1,
			}, {
				button = create_element(button, {
					text = if props.pending then "Creating..." else "Create!",
					colour = CREATE_COLOUR,
					interactable = can_create,
					on_activated = create,
				}),
			}),
		}),
	})
end

return guild_create_page
