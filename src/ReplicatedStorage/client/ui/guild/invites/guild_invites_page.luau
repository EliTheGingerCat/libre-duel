const ReplicatedStorage = game:GetService("ReplicatedStorage")

const React = require(ReplicatedStorage.Packages.react)
const SECTION_CARD_LAYOUT = require(script.Parent.Parent.Parent.profile_card.SECTION_CARD_LAYOUT)
const empty_state_text = require(script.Parent.Parent.Parent.visuals.empty_state_text)
const entrance_animation = require(script.Parent.Parent.Parent.effects.entrance_animation)
const guild_types = require(script.Parent.Parent.guild_types)
const player_banner_row = require(script.Parent.Parent.Parent.player_row.player_banner_row)
const player_name_label = require(script.Parent.Parent.Parent.player_row.player_name_label)
const player_row_card = require(script.Parent.Parent.Parent.player_row.player_row_card)
const player_row_types = require(script.Parent.Parent.Parent.player_row.player_row_types)
const scrolling_content = require(script.Parent.Parent.Parent.visuals.scrolling_content)
const section_card = require(script.Parent.Parent.Parent.profile_card.section_card)
const text_input = require(script.Parent.Parent.Parent.visuals.text_input)

const create_element = React.createElement

const INVITE_ICON = "rbxassetid://126059733701198"
const CANCEL_ICON = "rbxassetid://72160170469319"
const SEARCH_ICON = "rbxassetid://113215135352721"
const SEARCH_HEIGHT = 50
const ROW_GAP = 10
const PANEL_GAP = 20

const function create_invite_row(
	player: player_row_types.player_summary,
	layout_order: number,
	action_icon: string,
	on_action: (player_row_types.player_summary) -> ()
)
	const function activate(): ()
		on_action(player)
	end
	-- the entrance plays when a row moves from the results to outgoing invites and back
	return create_element(entrance_animation, { layout_order = layout_order }, {
		card = create_element(player_row_card, { name = tostring(player.user_id) }, {
			header = create_element(player_banner_row, {
				layout_order = 1,
				player = player,
				action_icon = action_icon,
				on_action = activate,
				content = create_element(player_name_label, {
					layout_order = 2,
					display_name = player.display_name,
					username = player.username,
				}),
			}),
		}),
	})
end

const function create_player_list(
	players: { player_row_types.player_summary },
	empty_text: string,
	action_icon: string,
	on_action: (player_row_types.player_summary) -> (),
	reset_key: string?
)
	const rows = {
		padding = create_element(
			"UIPadding",
			{ PaddingTop = UDim.new(0, ROW_GAP), PaddingBottom = UDim.new(0, ROW_GAP) }
		),
		layout = create_element(
			"UIListLayout",
			{ Padding = UDim.new(0, ROW_GAP), SortOrder = Enum.SortOrder.LayoutOrder }
		),
	}
	for index, player in players do
		rows[tostring(player.user_id)] = create_invite_row(player, index, action_icon, on_action)
	end
	if #players == 0 then
		rows.empty = create_element(empty_state_text, { text = empty_text })
	end
	return create_element(scrolling_content, {
		size = UDim2.fromScale(1, 1),
		reset_key = reset_key,
	}, rows)
end

const function guild_invites_page(props: { invites: guild_types.invites })
	const invites = props.invites
	const panel_size = UDim2.new(0.5, -PANEL_GAP / 2, 1, 0)
	return create_element("Frame", {
		Name = "invites",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
	}, {
		layout = create_element("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = UDim.new(0, PANEL_GAP),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
		invite_new = create_element(
			section_card,
			{ name = "invite_new", title = "Invite new", layout_order = 1, size = panel_size },
			{
				search = create_element("Frame", {
					LayoutOrder = 1,
					Size = UDim2.new(1, 0, 0, SEARCH_HEIGHT),
					BackgroundTransparency = 1,
				}, {
					input = create_element(text_input, {
						text = invites.query,
						placeholder = "Search...",
						icon = SEARCH_ICON,
						on_changed = invites.on_search,
					}),
				}),
				results = create_element("Frame", {
					LayoutOrder = 2,
					Size = UDim2.new(1, 0, 1, -SECTION_CARD_LAYOUT.title_height - SEARCH_HEIGHT),
					BackgroundTransparency = 1,
				}, {
					list = create_player_list(
						invites.search_results,
						if invites.query == ""
							then "Nobody else is here, search for a player to invite."
							else "No players found.",
						INVITE_ICON,
						invites.on_invite,
						invites.query
					),
				}),
			}
		),
		outgoing = create_element(
			section_card,
			{ name = "outgoing", title = "Outgoing invites", layout_order = 2, size = panel_size },
			{
				invites = create_element("Frame", {
					LayoutOrder = 1,
					Size = UDim2.new(1, 0, 1, -SECTION_CARD_LAYOUT.title_height),
					BackgroundTransparency = 1,
				}, {
					list = create_player_list(
						invites.outgoing,
						"No pending invites.",
						CANCEL_ICON,
						invites.on_cancel,
						nil
					),
				}),
			}
		),
	})
end

return guild_invites_page
