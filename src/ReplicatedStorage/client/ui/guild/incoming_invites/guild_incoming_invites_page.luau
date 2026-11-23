const ReplicatedStorage = game:GetService("ReplicatedStorage")

const React = require(ReplicatedStorage.Packages.react)
const empty_state_text = require(script.Parent.Parent.Parent.components.text.empty_state_text)
const guild_incoming_invite_card = require(script.Parent.guild_incoming_invite_card)
const guild_types = require(script.Parent.Parent.guild_types)

const create_element = React.createElement

const function guild_incoming_invites_page(
	props: {
		invites: { guild_types.incoming_invite },
		-- the guild id whose invite is being answered right now
		pending_guild_id: string?,
		on_accept: (invite: guild_types.incoming_invite) -> (),
		on_decline: (invite: guild_types.incoming_invite) -> (),
		on_manage: (invite: guild_types.incoming_invite, button: GuiObject) -> (),
	}
)
	const cards = {}
	for index, invite in props.invites do
		cards[invite.guild_id] = create_element(guild_incoming_invite_card, {
			invite = invite,
			layout_order = index,
			pending = props.pending_guild_id ~= nil,
			on_accept = props.on_accept,
			on_decline = props.on_decline,
			on_manage = props.on_manage,
		})
	end
	if #props.invites == 0 then
		cards.empty = create_element(empty_state_text, { text = "No guild invites yet." })
	end
	return create_element(React.Fragment, nil, cards)
end

return guild_incoming_invites_page
