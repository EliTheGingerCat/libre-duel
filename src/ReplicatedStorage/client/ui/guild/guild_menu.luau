const ReplicatedStorage = game:GetService("ReplicatedStorage")

const COLOURS = require(ReplicatedStorage.shared.ui.COLOURS)
const React = require(ReplicatedStorage.Packages.react)
const entrance_animation = require(script.Parent.Parent.effects.entrance_animation)
const guild_info_page = require(script.Parent.info.guild_info_page)
const guild_invites_page = require(script.Parent.invites.guild_invites_page)
const guild_manage_page = require(script.Parent.manage.guild_manage_page)
const guild_members_page = require(script.Parent.members.guild_members_page)
const guild_types = require(script.Parent.guild_types)
const member_context_menu = require(script.Parent.members.member_context_menu)
const menu_sidebar = require(script.Parent.Parent.sidebar.menu_sidebar)
const menu_window = require(script.Parent.Parent.visuals.menu_window)
const scrolling_content = require(script.Parent.Parent.visuals.scrolling_content)
const sidebar_types = require(script.Parent.Parent.sidebar.sidebar_types)

const create_element = React.createElement

const INFO_ENTRY: sidebar_types.entry = { id = "info", text = "Info", icon = "rbxassetid://75711772548687" }
const MEMBERS_ENTRY: sidebar_types.entry = { id = "members", text = "Members", icon = "rbxassetid://100734044686485" }
const INVITES_ENTRY: sidebar_types.entry = { id = "invites", text = "Invites", icon = "rbxassetid://126059733701198" }
const MANAGE_ENTRY: sidebar_types.entry =
	{ id = "manage", text = "Manage", icon = "rbxassetid://104330757164550", bottom = true }
const LEAVE_ENTRY: sidebar_types.entry = {
	id = "leave",
	text = "Leave",
	icon = "rbxassetid://82008498319027",
	colour = COLOURS.danger_text,
	bottom = true,
}
-- owners manage the guild instead of leaving it
const OWNER_ENTRIES = { INFO_ENTRY, MEMBERS_ENTRY, INVITES_ENTRY, MANAGE_ENTRY }
const MEMBER_ENTRIES = { INFO_ENTRY, MEMBERS_ENTRY, LEAVE_ENTRY }

type context_menu_state = { member: guild_types.member, position: UDim2 }

export type props = {
	enabled: boolean,
	on_close: () -> (),
	guild: guild_types.guild,
	viewer_is_owner: boolean,
	invites: guild_types.invites,
}

const function guild_menu(props: props)
	const selected, set_selected = React.useState("info" :: guild_types.page)
	const context_menu: context_menu_state?, set_context_menu: (context_menu_state?) -> () =
		React.useState(nil :: context_menu_state?)
	const overlay_ref = React.useRef(nil :: Frame?)

	const function select_entry(id: string): ()
		-- TODO: hook leaving up once guilds exist on the server
		if id == "leave" then
			return
		end
		set_context_menu(nil)
		set_selected(id :: guild_types.page)
	end
	const function open_member_menu(member: guild_types.member, button: GuiObject): ()
		const overlay = overlay_ref.current
		if not overlay then
			return
		end
		-- stored as a fraction of the window so it stays put no matter how the window is scaled
		const target = button.AbsolutePosition + Vector2.new(button.AbsoluteSize.X, button.AbsoluteSize.Y / 2)
		const relative = (target - overlay.AbsolutePosition) / overlay.AbsoluteSize
		set_context_menu({ member = member, position = UDim2.fromScale(relative.X, relative.Y) })
	end
	const function close_member_menu(): ()
		set_context_menu(nil)
	end
	-- TODO: hook these up once guilds exist on the server
	const function member_action(_action: member_context_menu.action): ()
		set_context_menu(nil)
	end
	const function delete_guild(): () end
	const function reset_when_closed(): ()
		if not props.enabled then
			set_context_menu(nil)
		end
	end
	React.useEffect(reset_when_closed, { props.enabled })

	const page = if selected == "members"
		then create_element(guild_members_page, { members = props.guild.members, on_manage_member = open_member_menu })
		elseif selected == "invites" then create_element(guild_invites_page, { invites = props.invites })
		elseif selected == "manage" then create_element(guild_manage_page, { on_delete_guild = delete_guild })
		else create_element(guild_info_page, { guild = props.guild })
	-- the invites page scrolls each of its panels on its own, so it gets a fixed height instead of the scrolling page
	const page_scrolls_itself = selected == "invites"
	const content_position = UDim2.new(0.28, 0, 0, 76)
	const content_size = UDim2.new(0.72, -32, 1, -96)

	return create_element(menu_window, {
		name = "Guild",
		title = "Guild",
		enabled = props.enabled,
		on_close = props.on_close,
	}, props.enabled and {
		sidebar = create_element(menu_sidebar, {
			entries = if props.viewer_is_owner then OWNER_ENTRIES else MEMBER_ENTRIES,
			selected = selected,
			on_selected = select_entry,
		}),
		content = if page_scrolls_itself
			then create_element("Frame", {
				Position = content_position,
				Size = content_size,
				BackgroundTransparency = 1,
			}, {
				page = create_element(entrance_animation, { key = selected, fill = true }, { page = page }),
			})
			else create_element(scrolling_content, {
				position = content_position,
				size = content_size,
				reset_key = selected,
			}, {
				layout = create_element("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder }),
				page = create_element(entrance_animation, { key = selected }, {
					layout = create_element(
						"UIListLayout",
						{ Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder }
					),
					page = page,
				}),
			}),
		-- lives outside the scrolling content so the context menu is never clipped by it
		overlay = create_element("Frame", {
			ref = overlay_ref,
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			Interactable = context_menu ~= nil,
			ZIndex = 5,
		}, context_menu and {
			dismiss = create_element("TextButton", {
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				Text = "",
				[React.Event.Activated] = close_member_menu,
			}),
			menu = create_element(member_context_menu, {
				key = tostring(context_menu.member.user_id) .. tostring(context_menu.position),
				position = context_menu.position + UDim2.fromOffset(8, 0),
				viewer_is_owner = props.viewer_is_owner,
				on_action = member_action,
			}),
		}),
	})
end

return guild_menu
