const ReplicatedStorage = game:GetService("ReplicatedStorage")

const GUILD_LIMITS = require(ReplicatedStorage.shared.guild.GUILD_LIMITS)
const React = require(ReplicatedStorage.Packages.react)
const editable_guild_description = require(script.Parent.editable_guild_description)
const guild_types = require(script.Parent.Parent.guild_types)
const highlight_stats = require(script.Parent.Parent.Parent.profile_card.highlight_stats)
const info_fields = require(script.Parent.Parent.Parent.profile_card.info_fields)
const rank_history_graph = require(script.Parent.Parent.Parent.profile_card.rank_history.rank_history_graph)
const profile_header = require(script.Parent.Parent.Parent.profile_card.profile_header)
const rich_text_description = require(script.Parent.Parent.Parent.profile_card.rich_text_description)
const section_card = require(script.Parent.Parent.Parent.profile_card.section_card)

const create_element = React.createElement

export type edit_actions = {
	on_rename: (name: string) -> (),
	on_edit_description: (description: string) -> (),
	on_change_icon: () -> (),
	on_change_banner: () -> (),
}

-- edit is only given to the owner, everyone else sees a plain page
const function guild_info_page(props: { guild: guild_types.guild, edit: edit_actions? })
	const guild = props.guild
	const edit = props.edit
	return create_element(React.Fragment, nil, {
		header = create_element(profile_header, {
			layout_order = 1,
			banner = guild.banner,
			icon = guild.icon,
			name = guild.name,
			subtitle = `[{guild.tag}]`,
			on_banner_activated = if edit then edit.on_change_banner else nil,
			on_icon_activated = if edit then edit.on_change_icon else nil,
			on_name_changed = if edit then edit.on_rename else nil,
			name_max_length = GUILD_LIMITS.MAX_NAME_LENGTH,
		}),
		information = create_element(section_card, { name = "information", title = "Guild info", layout_order = 2 }, {
			fields = create_element(info_fields, { fields = guild.info_fields }),
		}),
		stats = create_element(section_card, { name = "guild_stats", title = "Guild stats", layout_order = 3 }, {
			highlights = create_element(highlight_stats, { stats = guild.highlight_stats }),
			rank_history = #guild.rank_history > 0
				and create_element(rank_history_graph, { history = guild.rank_history, layout_order = 100 }),
		}),
		about = create_element(section_card, { name = "about", title = "About", layout_order = 4 }, {
			description = if edit
				then create_element(editable_guild_description, {
					text = guild.about,
					max_length = GUILD_LIMITS.MAX_DESCRIPTION_LENGTH,
					on_changed = edit.on_edit_description,
				})
				else create_element(rich_text_description, { text = guild.about }),
		}),
	})
end

return guild_info_page
