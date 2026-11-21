const ReplicatedStorage = game:GetService("ReplicatedStorage")

const React = require(ReplicatedStorage.Packages.react)
const entrance_animation = require(script.Parent.Parent.effects.entrance_animation)
const highlight_stats = require(script.Parent.Parent.profile_card.highlight_stats)
const info_fields = require(script.Parent.Parent.profile_card.info_fields)
const menu_window = require(script.Parent.Parent.visuals.menu_window)
const player_profile_types = require(script.Parent.player_profile_types)
const profile_header = require(script.Parent.Parent.profile_card.profile_header)
const rank_history_graph = require(script.Parent.Parent.profile_card.rank_history.rank_history_graph)
const rich_text_description = require(script.Parent.Parent.profile_card.rich_text_description)
const scrolling_content = require(script.Parent.Parent.visuals.scrolling_content)
const section_card = require(script.Parent.Parent.profile_card.section_card)
const stat_groups = require(script.Parent.Parent.profile_card.stat_groups)

const create_element = React.createElement

const function player_profile_menu(props: {
	enabled: boolean,
	on_close: () -> (),
	profile: player_profile_types.player_profile,
})
	const profile = props.profile
	return create_element(menu_window, {
		name = "Player profile",
		title = "Profile",
		enabled = props.enabled,
		on_close = props.on_close,
	}, props.enabled and {
		content = create_element(scrolling_content, {
			anchor = Vector2.new(0.5, 1),
			position = UDim2.fromScale(0.5, 1),
			size = UDim2.new(0.8, -20, 1, -76),
			reset_key = profile.username,
		}, {
			padding = create_element("UIPadding", {
				PaddingTop = UDim.new(0, 12),
				PaddingBottom = UDim.new(0, 20),
				PaddingLeft = UDim.new(0, 40),
				PaddingRight = UDim.new(0, 40),
			}),
			layout = create_element("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder }),
			page = create_element(entrance_animation, { key = profile.username }, {
				layout = create_element(
					"UIListLayout",
					{ Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder }
				),
				header = create_element(profile_header, {
					layout_order = 1,
					banner = profile.banner,
					icon = profile.headshot,
					name = profile.display_name,
					subtitle = `@{profile.username}`,
				}),
				information = create_element(
					section_card,
					{ name = "information", title = "Player info", layout_order = 2 },
					{
						fields = create_element(info_fields, { fields = profile.info_fields }),
					}
				),
				quick_stats = create_element(
					section_card,
					{ name = "quick_stats", title = "Quick stats", layout_order = 3 },
					{
						highlights = create_element(highlight_stats, { stats = profile.highlight_stats }),
						rank_history = #profile.rank_history > 0 and create_element(
							rank_history_graph,
							{ history = profile.rank_history, layout_order = 100 }
						),
					}
				),
				bio = create_element(section_card, { name = "bio", title = "Bio", layout_order = 4 }, {
					description = create_element(rich_text_description, { text = profile.bio }),
				}),
				stats = create_element(section_card, { name = "stats", title = "Stats", layout_order = 5 }, {
					groups = create_element(stat_groups, { groups = profile.stats, layout_order = 1 }),
				}),
			}),
		}),
	})
end

return player_profile_menu
