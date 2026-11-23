const ReplicatedStorage = game:GetService("ReplicatedStorage")

const FONTS = require(ReplicatedStorage.shared.ui.FONTS)
const PLAYER_ROW_LAYOUT = require(script.Parent.Parent.Parent.player_row.PLAYER_ROW_LAYOUT)
const React = require(ReplicatedStorage.Packages.react)
const animated_button = require(script.Parent.Parent.Parent.components.buttons.animated_button)
const button_motion = require(script.Parent.Parent.Parent.components.buttons.button_motion)
const escape_rich_text = require(ReplicatedStorage.shared.ui.escape_rich_text)
const guild_invite_response_button = require(script.Parent.guild_invite_response_button)
const guild_types = require(script.Parent.Parent.guild_types)

const create_element = React.createElement

const CARD_HEIGHT = 192
const CARD_PADDING = 12
const MANAGE_ICON = "rbxassetid://126734453814705"
const ACCEPT_COLOUR = Color3.fromRGB(172, 255, 120)
const DECLINE_COLOUR = Color3.fromRGB(255, 123, 123)
const SUBTITLE_COLOUR = Color3.fromRGB(200, 200, 200)

const function create_text(text: string, text_size: number, colour: Color3, font: Font, layout_order: number)
	return create_element("TextLabel", {
		LayoutOrder = layout_order,
		Size = UDim2.fromScale(1, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		FontFace = font,
		Text = text,
		TextSize = text_size,
		TextColor3 = colour,
		TextTruncate = Enum.TextTruncate.AtEnd,
		TextXAlignment = Enum.TextXAlignment.Left,
	})
end

const function guild_incoming_invite_card(
	props: {
		invite: guild_types.incoming_invite,
		layout_order: number,
		-- true while a response is being sent, so a second click can't double accept
		pending: boolean,
		on_accept: (invite: guild_types.incoming_invite) -> (),
		on_decline: (invite: guild_types.incoming_invite) -> (),
		on_manage: (invite: guild_types.incoming_invite, button: GuiObject) -> (),
	}
)
	const invite = props.invite
	const function accept(): ()
		props.on_accept(invite)
	end
	const function decline(): ()
		props.on_decline(invite)
	end
	const function manage(button: GuiObject): ()
		props.on_manage(invite, button)
	end
	const member_word = if invite.member_count == 1 then "member" else "members"
	return create_element("CanvasGroup", {
		Name = invite.guild_id,
		LayoutOrder = props.layout_order,
		Size = UDim2.new(1, 0, 0, CARD_HEIGHT),
		BackgroundColor3 = PLAYER_ROW_LAYOUT.background,
	}, {
		corner = create_element("UICorner", { CornerRadius = UDim.new(0, 32) }),
		banner = create_element("ImageLabel", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			Image = invite.banner,
			ScaleType = Enum.ScaleType.Crop,
		}, {
			fade = create_element("UIGradient", { Transparency = PLAYER_ROW_LAYOUT.banner_fade }),
		}),
		row = create_element("Frame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			ZIndex = 2,
		}, {
			padding = create_element("UIPadding", {
				PaddingTop = UDim.new(0, CARD_PADDING),
				PaddingBottom = UDim.new(0, CARD_PADDING),
				PaddingLeft = UDim.new(0, CARD_PADDING),
				PaddingRight = UDim.new(0, 64),
			}),
			layout = create_element("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				Padding = UDim.new(0, 10),
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),
			icon = create_element("ImageLabel", {
				LayoutOrder = 1,
				Size = UDim2.fromScale(1, 1),
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				BackgroundTransparency = 1,
				Image = invite.icon,
				ScaleType = Enum.ScaleType.Crop,
			}, {
				corner = create_element("UICorner", { CornerRadius = UDim.new(0, 22) }),
			}),
			details = create_element("Frame", {
				LayoutOrder = 2,
				Size = UDim2.fromScale(0, 1),
				BackgroundTransparency = 1,
			}, {
				flex = create_element("UIFlexItem", { FlexMode = Enum.UIFlexMode.Fill }),
				layout = create_element("UIListLayout", {
					Padding = UDim.new(0, 10),
					SortOrder = Enum.SortOrder.LayoutOrder,
				}),
				info = create_element("Frame", {
					LayoutOrder = 1,
					Size = UDim2.fromScale(1, 0),
					AutomaticSize = Enum.AutomaticSize.Y,
					BackgroundTransparency = 1,
				}, {
					layout = create_element("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder }),
					name = create_text(invite.name, 48, Color3.new(1, 1, 1), FONTS.semi_bold, 1),
					tag = create_text(`[{invite.tag}]`, 32, Color3.new(1, 1, 1), FONTS.semi_bold, 2),
					invited_by = create_text(
						`Invited by @{escape_rich_text(invite.inviter_username)}, {invite.member_count} {member_word}`,
						32,
						SUBTITLE_COLOUR,
						FONTS.regular,
						3
					),
				}),
				buttons = create_element("Frame", {
					LayoutOrder = 2,
					Size = UDim2.fromScale(0.5, 0),
					AutomaticSize = Enum.AutomaticSize.Y,
					BackgroundTransparency = 1,
				}, {
					layout = create_element("UIListLayout", {
						FillDirection = Enum.FillDirection.Horizontal,
						HorizontalFlex = Enum.UIFlexAlignment.Fill,
						Padding = UDim.new(0, 20),
						SortOrder = Enum.SortOrder.LayoutOrder,
					}),
					accept = create_element(guild_invite_response_button, {
						text = "Accept",
						colour = ACCEPT_COLOUR,
						layout_order = 1,
						interactable = not props.pending,
						on_activated = accept,
					}),
					decline = create_element(guild_invite_response_button, {
						text = "Decline",
						colour = DECLINE_COLOUR,
						layout_order = 2,
						interactable = not props.pending,
						on_activated = decline,
					}),
				}),
			}),
		}),
		manage = create_element(animated_button, {
			class_name = "ImageButton",
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -PLAYER_ROW_LAYOUT.action_inset, 0.5, 0),
			Size = UDim2.fromOffset(PLAYER_ROW_LAYOUT.action_size, PLAYER_ROW_LAYOUT.action_size),
			BackgroundTransparency = 1,
			Image = MANAGE_ICON,
			ZIndex = 3,
			[React.Event.Activated] = manage,
		}, { feedback = create_element(button_motion) }),
	})
end

return guild_incoming_invite_card
