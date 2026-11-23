const ReplicatedStorage = game:GetService("ReplicatedStorage")

const React = require(ReplicatedStorage.Packages.react)
const highlight_stats = require(script.Parent.highlight_stats)
const profile_types = require(script.Parent.profile_types)
const section_card = require(script.Parent.section_card)

const create_element = React.createElement

-- one card per section, used for the full numbers behind the quick stats
const function stat_section_cards(props: { sections: { profile_types.stat_section } })
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

return stat_section_cards
