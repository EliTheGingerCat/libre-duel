const ReplicatedStorage = game:GetService("ReplicatedStorage")

const FONTS = require(ReplicatedStorage.shared.ui.FONTS)
const React = require(ReplicatedStorage.Packages.react)
const editable_image_overlay = require(script.Parent.editable_image_overlay)

const create_element = React.createElement
const BANNER_ASPECT_RATIO = 5
-- room under the banner for the icon and name, which hang below it
const OVERHANG_HEIGHT = 100
const ICON_CORNER = UDim.new(0.4, 0)

export type props = {
	banner: string,
	icon: string,
	name: string,
	subtitle: string,
	layout_order: number?,
	-- each one makes its part editable, leave them out for headers only meant to be looked at
	on_banner_activated: (() -> ())?,
	on_icon_activated: (() -> ())?,
	-- turns the name into a textbox, called with the new name when the viewer presses enter or clicks away
	on_name_changed: ((name: string) -> ())?,
	name_max_length: number?,
}

const function truncate_to(text: string, max_length: number?): string
	if max_length == nil or (utf8.len(text) or #text) <= max_length then
		return text
	end
	const cut_at = utf8.offset(text, max_length + 1)
	return if cut_at then string.sub(text, 1, cut_at - 1) else text
end

-- banner with a big rounded icon and a name overlapping its bottom edge
const function profile_header(props: props)
	-- the icon sits on top of the banner, so the banner gets no MouseLeave when the cursor moves onto the icon
	const banner_hovered, set_banner_hovered = React.useState(false)
	const icon_hovered, set_icon_hovered = React.useState(false)
	const function limit_name_length(box: TextBox): ()
		const truncated = truncate_to(box.Text, props.name_max_length)
		if truncated ~= box.Text then
			box.Text = truncated
		end
	end
	const function submit_name(box: TextBox): ()
		const new_name = box.Text
		if props.on_name_changed == nil or new_name == props.name or string.match(new_name, "^%s*$") then
			box.Text = props.name
			return
		end
		props.on_name_changed(new_name)
	end
	const name_is_editable = props.on_name_changed ~= nil
	return create_element("Frame", {
		Name = "profile_header",
		LayoutOrder = props.layout_order,
		Size = UDim2.fromScale(1, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
	}, {
		layout = create_element("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder }),
		banner_area = create_element("Frame", {
			LayoutOrder = 1,
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
		}, {
			aspect = create_element("UIAspectRatioConstraint", { AspectRatio = BANNER_ASPECT_RATIO }),
			banner = create_element("ImageLabel", {
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				Image = props.banner,
				ScaleType = Enum.ScaleType.Crop,
			}, {
				edit = props.on_banner_activated and create_element(editable_image_overlay, {
					hint = "Change banner",
					shaded = banner_hovered and not icon_hovered,
					on_hover_changed = set_banner_hovered,
					on_activated = props.on_banner_activated,
				}),
			}),
			icon = create_element("ImageLabel", {
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.fromScale(0.05, 1),
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				Image = props.icon,
				ScaleType = Enum.ScaleType.Crop,
				ZIndex = 2,
			}, {
				aspect = create_element("UIAspectRatioConstraint"),
				corner = create_element("UICorner", { CornerRadius = ICON_CORNER }),
				edit = props.on_icon_activated and create_element(editable_image_overlay, {
					hint = "Change icon",
					corner_radius = ICON_CORNER,
					shaded = icon_hovered,
					on_hover_changed = set_icon_hovered,
					on_activated = props.on_icon_activated,
				}),
			}),
			name_container = create_element("Frame", {
				AnchorPoint = Vector2.new(1, 0),
				Position = UDim2.fromScale(1, 1),
				Size = UDim2.fromScale(0.74, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1,
				ZIndex = 2,
			}, {
				layout = create_element("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder }),
				padding = create_element("UIPadding", {
					PaddingTop = UDim.new(0, 5),
					PaddingBottom = UDim.new(0, 5),
					PaddingLeft = UDim.new(0, 5),
					PaddingRight = UDim.new(0, 5),
				}),
				name = create_element(if name_is_editable then "TextBox" else "TextLabel", {
					LayoutOrder = 1,
					ClearTextOnFocus = if name_is_editable then false else nil,
					[React.Change.Text] = if name_is_editable then limit_name_length else nil,
					[React.Event.FocusLost] = if name_is_editable then submit_name else nil,
					Size = UDim2.new(1, 0, 0, 42),
					AutomaticSize = Enum.AutomaticSize.Y,
					BackgroundTransparency = 1,
					FontFace = FONTS.semi_bold,
					Text = props.name,
					TextSize = 48,
					TextColor3 = Color3.new(1, 1, 1),
					TextXAlignment = Enum.TextXAlignment.Left,
					TextWrapped = true,
				}),
				subtitle = create_element("TextLabel", {
					LayoutOrder = 2,
					Size = UDim2.new(1, 0, 0, 32),
					BackgroundTransparency = 1,
					FontFace = FONTS.semi_bold,
					Text = props.subtitle,
					TextSize = 32,
					TextColor3 = Color3.new(1, 1, 1),
					TextXAlignment = Enum.TextXAlignment.Left,
					TextTruncate = Enum.TextTruncate.AtEnd,
				}),
			}),
		}),
		overhang = create_element("Frame", {
			LayoutOrder = 2,
			Size = UDim2.new(1, 0, 0, OVERHANG_HEIGHT),
			BackgroundTransparency = 1,
		}),
	})
end

return profile_header
