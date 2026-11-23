const ReplicatedStorage = game:GetService("ReplicatedStorage")

const COLOURS = require(ReplicatedStorage.shared.ui.COLOURS)
const React = require(ReplicatedStorage.Packages.react)
const empty_state_text = require(script.Parent.Parent.visuals.empty_state_text)
const entrance_animation = require(script.Parent.Parent.effects.entrance_animation)
const menu_sidebar = require(script.Parent.Parent.sidebar.menu_sidebar)
const menu_window = require(script.Parent.Parent.visuals.menu_window)
const player_info_page = require(script.Parent.info.player_info_page)
const player_profile_types = require(script.Parent.player_profile_types)
const scrolling_content = require(script.Parent.Parent.visuals.scrolling_content)
const sidebar_types = require(script.Parent.Parent.sidebar.sidebar_types)
const stat_section_cards = require(script.Parent.Parent.profile_card.stat_section_cards)

const create_element = React.createElement

const INFO_ENTRY: sidebar_types.entry = { id = "info", text = "Info", icon = "rbxassetid://75711772548687" }
const STATS_ENTRY: sidebar_types.entry = { id = "stats", text = "Stats", icon = "rbxassetid://128265647801507" }
const REPORT_ENTRY: sidebar_types.entry = {
	id = "report",
	text = "Report",
	icon = "rbxassetid://94356225732345",
	colour = COLOURS.danger_text,
	bottom = true,
}
-- nobody needs to report themselves
const OWN_ENTRIES = { INFO_ENTRY, STATS_ENTRY }
const OTHER_ENTRIES = { INFO_ENTRY, STATS_ENTRY, REPORT_ENTRY }

export type props = {
	enabled: boolean,
	on_close: () -> (),
	-- nil while it loads
	profile: player_profile_types.player_profile?,
	failed: boolean,
	viewer_is_self: boolean,
	actions: player_profile_types.actions,
}

const function player_profile_menu(props: props)
	const selected, set_selected = React.useState("info" :: player_profile_types.page)
	const profile = props.profile
	const profile_user_id = if profile then profile.user_id else nil

	const function reset_page_when_player_changes(): ()
		set_selected("info")
	end
	React.useEffect(reset_page_when_player_changes, { profile_user_id })

	const function select_entry(id: string): ()
		if id == "report" then
			props.actions.on_report()
			return
		end
		set_selected(id :: player_profile_types.page)
	end

	local page: unknown = nil
	local page_key: string = selected
	if profile == nil then
		page_key = "loading"
		page = create_element(empty_state_text, {
			text = if props.failed then "Couldn't load this profile." else "Loading profile...",
			text_size = 30,
		})
	elseif selected == "stats" then
		page_key = `stats_{profile.user_id}`
		page = create_element(stat_section_cards, { sections = profile.stat_sections })
	else
		page_key = `info_{profile.user_id}`
		page = create_element(player_info_page, {
			profile = profile,
			edit = if props.viewer_is_self
				then { on_change_banner = props.actions.on_change_banner, on_edit_bio = props.actions.on_edit_bio }
				else nil,
		})
	end

	return create_element(menu_window, {
		name = "PlayerProfile",
		title = "Player profile",
		enabled = props.enabled,
		on_close = props.on_close,
	}, props.enabled and {
		sidebar = create_element(menu_sidebar, {
			entries = if props.viewer_is_self then OWN_ENTRIES else OTHER_ENTRIES,
			selected = selected,
			on_selected = select_entry,
		}),
		content = create_element(scrolling_content, {
			position = UDim2.new(0.28, 0, 0, 76),
			size = UDim2.new(0.72, -32, 1, -96),
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
	})
end

return player_profile_menu
