const ReplicatedStorage = game:GetService("ReplicatedStorage")

const React = require(ReplicatedStorage.Packages.react)
const guild_types = require(script.Parent.Parent.guild_types)
const highlight_stats = require(script.Parent.Parent.Parent.profile_card.highlight_stats)
const section_card = require(script.Parent.Parent.Parent.profile_card.section_card)

const create_element = React.createElement

-- the full numbers behind the quick stats on the info page, overall then split by mode
const function guild_stats_page(props: { sections: { guild_types.stat_section } })
	const cards = {}
	for index, section in props.sections do
		cards[section.id] = create_element(
			section_card,
			{ name = section.id, title = section.title, title_colour = section.title_colour, layout_order = index },
			{ stats = create_element(highlight_stats, { stats = section.stats }) }
		)
	end
	return create_element(React.Fragment, nil, cards)
end

return guild_stats_page
