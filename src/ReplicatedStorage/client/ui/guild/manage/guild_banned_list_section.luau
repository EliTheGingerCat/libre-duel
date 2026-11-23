const ReplicatedStorage = game:GetService("ReplicatedStorage")

const React = require(ReplicatedStorage.Packages.react)
const banned_member_row = require(script.Parent.banned_member_row)
const empty_state_text = require(script.Parent.Parent.Parent.components.text.empty_state_text)
const guild_types = require(script.Parent.Parent.guild_types)
const member_header_row = require(script.Parent.Parent.members.member_header_row)
const scrolling_content = require(script.Parent.Parent.Parent.components.layout.scrolling_content)
const section_card = require(script.Parent.Parent.Parent.profile_card.section_card)

const create_element = React.createElement
const LIST_HEIGHT = 256
const ROW_GAP = 10

const function guild_banned_list_section(props: {
	banned: { guild_types.banned_member },
	layout_order: number?,
	on_manage_banned: (banned_member: guild_types.banned_member, button: GuiObject) -> (),
})
	const rows = {
		padding = create_element("UIPadding", { PaddingTop = UDim.new(0, ROW_GAP) }),
		layout = create_element(
			"UIListLayout",
			{ Padding = UDim.new(0, ROW_GAP), SortOrder = Enum.SortOrder.LayoutOrder }
		),
	}
	for index, banned_member in props.banned do
		rows[tostring(banned_member.user_id)] = create_element(banned_member_row, {
			banned_member = banned_member,
			layout_order = index,
			on_manage = props.on_manage_banned,
		})
	end
	if #props.banned == 0 then
		rows.empty = create_element(empty_state_text, { text = "Nobody is banned." })
	end
	return create_element(section_card, {
		name = "banned_players",
		title = "Banned players",
		layout_order = props.layout_order,
		padding_bottom = 30,
	}, {
		header_row = create_element(member_header_row, { layout_order = 1, date_label = "Banned" }),
		list = create_element("Frame", {
			LayoutOrder = 2,
			Size = UDim2.new(1, 0, 0, LIST_HEIGHT),
			BackgroundTransparency = 1,
		}, {
			scroller = create_element(scrolling_content, { size = UDim2.fromScale(1, 1) }, rows),
		}),
	})
end

return guild_banned_list_section
