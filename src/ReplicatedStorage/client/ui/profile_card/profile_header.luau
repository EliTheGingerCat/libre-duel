const ReplicatedStorage = game:GetService("ReplicatedStorage")

const FONTS = require(ReplicatedStorage.shared.ui.FONTS)
const React = require(ReplicatedStorage.Packages.react)

const create_element = React.createElement
const BANNER_ASPECT_RATIO = 5
-- room under the banner for the icon and name, which hang below it
const OVERHANG_HEIGHT = 100

export type props = {
	banner: string,
	icon: string,
	name: string,
	subtitle: string,
	layout_order: number?,
}

-- banner with a big rounded icon and a name overlapping its bottom edge
const function profile_header(props: props)
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
				corner = create_element("UICorner", { CornerRadius = UDim.new(0.4, 0) }),
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
				name = create_element("TextLabel", {
					LayoutOrder = 1,
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
