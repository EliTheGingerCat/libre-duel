const ReplicatedStorage = game:GetService("ReplicatedStorage")

const COLOURS = require(ReplicatedStorage.shared.ui.COLOURS)
const GUILD_CONTEXT_MENU_OPTIONS = require(script.Parent.context_menu.GUILD_CONTEXT_MENU_OPTIONS)
const React = require(ReplicatedStorage.Packages.react)
const entrance_animation = require(script.Parent.Parent.effects.entrance_animation)
const guild_context_menu = require(script.Parent.context_menu.guild_context_menu)
const guild_context_menu_types = require(script.Parent.context_menu.guild_context_menu_types)
const guild_create_page = require(script.Parent.create.guild_create_page)
const guild_incoming_invites_page = require(script.Parent.incoming_invites.guild_incoming_invites_page)
const guild_info_page = require(script.Parent.info.guild_info_page)
const guild_invites_page = require(script.Parent.invites.guild_invites_page)
const guild_manage_page = require(script.Parent.manage.guild_manage_page)
const guild_members_page = require(script.Parent.members.guild_members_page)
const guild_stats_page = require(script.Parent.stats.guild_stats_page)
const guild_types = require(script.Parent.guild_types)
const menu_sidebar = require(script.Parent.Parent.sidebar.menu_sidebar)
const menu_window = require(script.Parent.Parent.visuals.menu_window)
const scrolling_content = require(script.Parent.Parent.visuals.scrolling_content)
const sidebar_types = require(script.Parent.Parent.sidebar.sidebar_types)

const create_element = React.createElement

const INFO_ENTRY: sidebar_types.entry = { id = "info", text = "Info", icon = "rbxassetid://75711772548687" }
-- borrows the info icon until there is a proper stats one
const STATS_ENTRY: sidebar_types.entry = { id = "stats", text = "Stats", icon = "rbxassetid://128265647801507" }
const MEMBERS_ENTRY: sidebar_types.entry = { id = "members", text = "Members", icon = "rbxassetid://100734044686485" }
const INVITES_ENTRY: sidebar_types.entry = { id = "invites", text = "Invites", icon = "rbxassetid://125391154286649" }
const MANAGE_ENTRY: sidebar_types.entry =
	{ id = "manage", text = "Manage", icon = "rbxassetid://104330757164550", bottom = true }
const CREATE_ENTRY: sidebar_types.entry = { id = "create", text = "Create", icon = "rbxassetid://127844573570900" }
const INCOMING_INVITES_ENTRY: sidebar_types.entry =
	{ id = "incoming_invites", text = "Invites", icon = "rbxassetid://125391154286649" }
const LEAVE_ICON = "rbxassetid://82008498319027"
-- owners manage the guild instead of leaving it
const OWNER_ENTRIES = { INFO_ENTRY, STATS_ENTRY, MEMBERS_ENTRY, INVITES_ENTRY, MANAGE_ENTRY }
const NO_GUILD_ENTRIES = { CREATE_ENTRY, INCOMING_INVITES_ENTRY }
-- leaving needs a second press, it resets after this long
const LEAVE_CONFIRM_TIMEOUT = 3

type context_menu_target =
	{ kind: "member", member: guild_types.member }
	| { kind: "banned_member", banned_member: guild_types.banned_member }
	| { kind: "incoming_invite", invite: guild_types.incoming_invite }
type context_menu_state = { target: context_menu_target, key: string, position: UDim2 }

export type props = {
	enabled: boolean,
	on_close: () -> (),
	-- nil when the viewer isn't in a guild, which shows the create and incoming invites pages instead
	guild: guild_types.guild?,
	-- another guild opened from an invite, shown read only over everything else
	viewed_guild: guild_types.guild?,
	viewer_is_owner: boolean,
	invites: guild_types.invites,
	incoming_invites: { guild_types.incoming_invite },
	creating: boolean,
	answering_invite_guild_id: string?,
	actions: guild_types.actions,
}

const function create_leave_entry(armed: boolean): sidebar_types.entry
	return {
		id = "leave",
		text = if armed then "Click again" else "Leave",
		icon = LEAVE_ICON,
		colour = COLOURS.danger_text,
		bottom = true,
	}
end

const function get_context_menu_options(
	target: context_menu_target,
	viewer_is_owner: boolean
): { guild_context_menu_types.option }
	if target.kind == "member" then
		return if viewer_is_owner and not target.member.is_owner
			then GUILD_CONTEXT_MENU_OPTIONS.member_for_owner
			else GUILD_CONTEXT_MENU_OPTIONS.member_for_member
	elseif target.kind == "banned_member" then
		return GUILD_CONTEXT_MENU_OPTIONS.banned_member
	end
	return GUILD_CONTEXT_MENU_OPTIONS.incoming_invite
end

const function guild_menu(props: props)
	const has_guild = props.guild ~= nil
	const selected, set_selected = React.useState((if has_guild then "info" else "create") :: guild_types.page)
	const context_menu: context_menu_state?, set_context_menu: (context_menu_state?) -> () =
		React.useState(nil :: context_menu_state?)
	const leave_armed, set_leave_armed = React.useState(false)
	const overlay_ref = React.useRef(nil :: Frame?)

	const function reset_page_when_guild_changes(): ()
		set_context_menu(nil)
		set_leave_armed(false)
		set_selected(if has_guild then "info" else "create")
	end
	React.useEffect(reset_page_when_guild_changes, { has_guild })

	const function disarm_leave_after_timeout(): (() -> ())?
		if not leave_armed then
			return nil
		end
		const timeout = task.delay(LEAVE_CONFIRM_TIMEOUT, set_leave_armed, false)
		const function cancel(): ()
			task.cancel(timeout)
		end
		return cancel
	end
	React.useEffect(disarm_leave_after_timeout, { leave_armed })

	const function reset_when_closed(): ()
		if not props.enabled then
			set_context_menu(nil)
			set_leave_armed(false)
		end
	end
	React.useEffect(reset_when_closed, { props.enabled })

	const function select_entry(id: string): ()
		set_context_menu(nil)
		if props.viewed_guild then
			props.actions.on_close_viewed_guild()
		end
		if id == "leave" then
			if leave_armed then
				set_leave_armed(false)
				props.actions.on_leave()
			else
				set_leave_armed(true)
			end
			return
		end
		set_leave_armed(false)
		set_selected(id :: guild_types.page)
	end

	const function open_context_menu(target: context_menu_target, key: string, button: GuiObject): ()
		const overlay = overlay_ref.current
		if not overlay then
			return
		end
		-- stored as a fraction of the window so it stays put no matter how the window is scaled
		const anchor = button.AbsolutePosition + Vector2.new(button.AbsoluteSize.X, button.AbsoluteSize.Y / 2)
		const relative = (anchor - overlay.AbsolutePosition) / overlay.AbsoluteSize
		set_context_menu({ target = target, key = key, position = UDim2.fromScale(relative.X, relative.Y) })
	end
	const function open_member_menu(member: guild_types.member, button: GuiObject): ()
		open_context_menu({ kind = "member", member = member }, `member_{member.user_id}`, button)
	end
	const function open_banned_member_menu(banned_member: guild_types.banned_member, button: GuiObject): ()
		open_context_menu(
			{ kind = "banned_member", banned_member = banned_member },
			`banned_{banned_member.user_id}`,
			button
		)
	end
	const function open_invite_menu(invite: guild_types.incoming_invite, button: GuiObject): ()
		open_context_menu({ kind = "incoming_invite", invite = invite }, `invite_{invite.guild_id}`, button)
	end
	const function close_context_menu(): ()
		set_context_menu(nil)
	end
	const function run_context_menu_action(id: string): ()
		const state = context_menu
		set_context_menu(nil)
		if state == nil then
			return
		end
		const target = state.target
		if target.kind == "member" then
			props.actions.on_member_action(id :: guild_types.member_action, target.member)
		elseif target.kind == "banned_member" then
			props.actions.on_banned_member_action(id :: guild_types.banned_member_action, target.banned_member)
		elseif id == "view_guild_info" then
			props.actions.on_view_guild_info(target.invite)
		elseif id == "block_guild" then
			props.actions.on_block_guild(target.invite)
		end
	end

	local page: unknown = nil
	local page_key: string = selected
	-- pages that scroll themselves or center their content get a fixed frame instead of the scrolling page
	local page_fills_content = false
	if props.viewed_guild then
		page = create_element(guild_info_page, { guild = props.viewed_guild })
		page_key = `viewed_{props.viewed_guild.id}`
	elseif props.guild == nil then
		if selected == "incoming_invites" then
			page = create_element(guild_incoming_invites_page, {
				invites = props.incoming_invites,
				pending_guild_id = props.answering_invite_guild_id,
				on_accept = props.actions.on_accept_invite,
				on_decline = props.actions.on_decline_invite,
				on_manage = open_invite_menu,
			})
		else
			page_key = "create"
			page_fills_content = true
			page = create_element(guild_create_page, { pending = props.creating, on_create = props.actions.on_create })
		end
	elseif selected == "stats" then
		page = create_element(guild_stats_page, { sections = props.guild.stat_sections })
	elseif selected == "members" then
		page =
			create_element(guild_members_page, { members = props.guild.members, on_manage_member = open_member_menu })
	elseif selected == "invites" and props.viewer_is_owner then
		page_fills_content = true
		page = create_element(guild_invites_page, { invites = props.invites })
	elseif selected == "manage" and props.viewer_is_owner then
		page = create_element(guild_manage_page, {
			banned = props.guild.banned,
			on_manage_banned = open_banned_member_menu,
			on_delete_guild = props.actions.on_delete,
		})
	else
		page_key = "info"
		page = create_element(guild_info_page, {
			guild = props.guild,
			edit = if props.viewer_is_owner
				then {
					on_rename = props.actions.on_rename,
					on_edit_description = props.actions.on_edit_description,
					on_change_icon = props.actions.on_change_icon,
					on_change_banner = props.actions.on_change_banner,
				}
				else nil,
		})
	end

	const content_position = UDim2.new(0.28, 0, 0, 76)
	const content_size = UDim2.new(0.72, -32, 1, -96)
	const entries = if props.guild == nil
		then NO_GUILD_ENTRIES
		elseif props.viewer_is_owner then OWNER_ENTRIES
		else { INFO_ENTRY, STATS_ENTRY, MEMBERS_ENTRY, create_leave_entry(leave_armed) }

	return create_element(menu_window, {
		name = "Guild",
		title = "Guild",
		enabled = props.enabled,
		on_close = props.on_close,
	}, props.enabled and {
		sidebar = create_element(menu_sidebar, {
			entries = entries,
			selected = if props.viewed_guild then "" else page_key,
			on_selected = select_entry,
		}),
		content = if page_fills_content
			then create_element("Frame", {
				Position = content_position,
				Size = content_size,
				BackgroundTransparency = 1,
			}, {
				page = create_element(entrance_animation, { key = page_key, fill = true }, { page = page }),
			})
			else create_element(scrolling_content, {
				position = content_position,
				size = content_size,
				reset_key = page_key,
			}, {
				layout = create_element("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder }),
				page = create_element(entrance_animation, { key = page_key }, {
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
				[React.Event.Activated] = close_context_menu,
			}),
			menu = create_element(guild_context_menu, {
				key = context_menu.key .. tostring(context_menu.position),
				position = context_menu.position + UDim2.fromOffset(8, 0),
				options = get_context_menu_options(context_menu.target, props.viewer_is_owner),
				on_action = run_context_menu_action,
			}),
		}),
	})
end

return guild_menu
