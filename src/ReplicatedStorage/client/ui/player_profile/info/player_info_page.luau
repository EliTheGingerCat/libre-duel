const ReplicatedStorage = game:GetService("ReplicatedStorage")

const PLAYER_PROFILE_LIMITS = require(ReplicatedStorage.shared.player_profile.PLAYER_PROFILE_LIMITS)
const React = require(ReplicatedStorage.Packages.react)
const editable_rich_text_description = require(script.Parent.Parent.Parent.profile_card.editable_rich_text_description)
const highlight_stats = require(script.Parent.Parent.Parent.profile_card.highlight_stats)
const info_fields = require(script.Parent.Parent.Parent.profile_card.info_fields)
const player_profile_types = require(script.Parent.Parent.player_profile_types)
const profile_header = require(script.Parent.Parent.Parent.profile_card.profile_header)
const rank_history_graph = require(script.Parent.Parent.Parent.profile_card.rank_history.rank_history_graph)
const rich_text_description = require(script.Parent.Parent.Parent.profile_card.rich_text_description)
const section_card = require(script.Parent.Parent.Parent.profile_card.section_card)

const create_element = React.createElement
const BIO_PLACEHOLDER = "Click to write a bio. Rich text works here."

export type edit_actions = {
	on_change_banner: () -> (),
	on_edit_bio: (bio: string) -> (),
}

-- edit is only given to the player looking at their own profile
-- the icon is always the headshot, so only the banner and bio can be changed
const function player_info_page(props: { profile: player_profile_types.player_profile, edit: edit_actions? })
	const profile = props.profile
	const edit = props.edit
	return create_element(React.Fragment, nil, {
		header = create_element(profile_header, {
			layout_order = 1,
			banner = profile.banner,
			icon = profile.headshot,
			name = profile.display_name,
			subtitle = `@{profile.username}`,
			on_banner_activated = if edit then edit.on_change_banner else nil,
		}),
		information = create_element(
			section_card,
			{ name = "information", title = "Player info", layout_order = 2 },
			{ fields = create_element(info_fields, { fields = profile.info_fields }) }
		),
		quick_stats = create_element(section_card, { name = "quick_stats", title = "Quick stats", layout_order = 3 }, {
			highlights = create_element(highlight_stats, { stats = profile.highlight_stats }),
			rank_history = #profile.rank_history > 0
				and create_element(rank_history_graph, { history = profile.rank_history, layout_order = 100 }),
		}),
		-- nothing to show when someone else never wrote one
		about = (edit or profile.bio ~= "")
			and create_element(section_card, { name = "about", title = "About", layout_order = 4 }, {
				description = if edit
					then create_element(editable_rich_text_description, {
						text = profile.bio,
						placeholder = BIO_PLACEHOLDER,
						max_length = PLAYER_PROFILE_LIMITS.MAX_BIO_LENGTH,
						on_changed = edit.on_edit_bio,
					})
					else create_element(rich_text_description, { text = profile.bio }),
			}),
	})
end

return player_info_page
