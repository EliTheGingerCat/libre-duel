const ReplicatedStorage = game:GetService("ReplicatedStorage")

const React = require(ReplicatedStorage.Packages.react)
const guild_types = require(script.Parent.Parent.guild_types)
const member_columns = require(script.Parent.Parent.members.member_columns)
const player_banner_row = require(script.Parent.Parent.Parent.player_row.player_banner_row)
const player_row_card = require(script.Parent.Parent.Parent.player_row.player_row_card)

const create_element = React.createElement
const MANAGE_ICON = "rbxassetid://126734453814705"

-- same widget as a member row minus the stats, the date column shows when they were banned
const function banned_member_row(props: {
	banned_member: guild_types.banned_member,
	layout_order: number?,
	on_manage: (banned_member: guild_types.banned_member, button: GuiObject) -> (),
})
	const banned_member = props.banned_member
	const function manage(button: GuiObject): ()
		props.on_manage(banned_member, button)
	end
	return create_element(
		player_row_card,
		{ name = tostring(banned_member.user_id), layout_order = props.layout_order },
		{
			header = create_element(player_banner_row, {
				layout_order = 1,
				player = banned_member,
				action_icon = MANAGE_ICON,
				on_action = manage,
				content = create_element(member_columns, {
					layout_order = 2,
					display_name = banned_member.display_name,
					username = `@{banned_member.username}`,
					joined = banned_member.banned,
				}),
			}),
		}
	)
end

return banned_member_row
