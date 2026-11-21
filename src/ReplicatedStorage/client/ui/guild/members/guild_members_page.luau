const ReplicatedStorage = game:GetService("ReplicatedStorage")

const React = require(ReplicatedStorage.Packages.react)
const guild_types = require(script.Parent.Parent.guild_types)
const member_header_row = require(script.Parent.member_header_row)
const member_row = require(script.Parent.member_row)
const section_card = require(script.Parent.Parent.Parent.profile_card.section_card)

const create_element = React.createElement

const function guild_members_page(props: {
	members: { guild_types.member },
	on_manage_member: (member: guild_types.member, button: GuiObject) -> (),
})
	const rows = {
		layout = create_element("UIListLayout", { Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder }),
		header_row = create_element(member_header_row, { layout_order = 0 }),
	}
	for index, member in props.members do
		rows[tostring(member.user_id)] =
			create_element(member_row, { member = member, layout_order = index, on_manage = props.on_manage_member })
	end
	return create_element(
		section_card,
		{ name = "members", title = "Members", layout_order = 1, padding_bottom = 30 },
		{
			member_list = create_element("Frame", {
				LayoutOrder = 1,
				Size = UDim2.fromScale(1, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1,
			}, rows),
		}
	)
end

return guild_members_page
