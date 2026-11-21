const ReplicatedStorage = game:GetService("ReplicatedStorage")

const React = require(ReplicatedStorage.Packages.react)
const collapsible_reveal = require(script.Parent.Parent.Parent.effects.collapsible_reveal)
const guild_types = require(script.Parent.Parent.guild_types)
const member_columns = require(script.Parent.member_columns)
const player_banner_row = require(script.Parent.Parent.Parent.player_row.player_banner_row)
const player_row_card = require(script.Parent.Parent.Parent.player_row.player_row_card)
const stat_groups = require(script.Parent.Parent.Parent.profile_card.stat_groups)

const create_element = React.createElement
const OWNER_PREFIX = "👑 "
const MANAGE_ICON = "rbxassetid://126734453814705"

const function member_row(props: {
	member: guild_types.member,
	layout_order: number?,
	on_manage: (member: guild_types.member, button: GuiObject) -> (),
})
	const member = props.member
	const expanded, set_expanded = React.useState(false)
	const function toggle_expanded(): ()
		set_expanded(not expanded)
	end
	const function manage(button: GuiObject): ()
		props.on_manage(member, button)
	end
	return create_element(player_row_card, { name = tostring(member.user_id), layout_order = props.layout_order }, {
		header = create_element(player_banner_row, {
			layout_order = 1,
			player = member,
			action_icon = MANAGE_ICON,
			on_action = manage,
			on_activated = toggle_expanded,
			content = create_element(member_columns, {
				layout_order = 2,
				display_name = if member.is_owner then OWNER_PREFIX .. member.display_name else member.display_name,
				username = `@{member.username}`,
				joined = member.joined,
			}),
		}),
		stats = create_element(collapsible_reveal, { shown = expanded, layout_order = 2, fade = true }, {
			groups = create_element(stat_groups, { groups = member.stats }),
		}),
	})
end

return member_row
