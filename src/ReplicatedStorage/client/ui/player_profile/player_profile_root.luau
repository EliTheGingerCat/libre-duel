const Players = game:GetService("Players")
const ReplicatedStorage = game:GetService("ReplicatedStorage")

const React = require(ReplicatedStorage.Packages.react)
const format_player_profile_snapshot = require(script.Parent.format.format_player_profile_snapshot)
const menu_navigation = require(script.Parent.Parent.navigation.menu_navigation)
const player_profile_menu = require(script.Parent.player_profile_menu)
const use_player_profile_actions = require(script.Parent.hooks.use_player_profile_actions)
const use_topbar_menu_icon = require(script.Parent.Parent.topbar.use_topbar_menu_icon)
const use_user_info_version = require(ReplicatedStorage.client.guild.use_user_info_version)
const use_viewed_player_profile = require(script.Parent.hooks.use_viewed_player_profile)
const user_info_cache = require(ReplicatedStorage.client.guild.user_info_cache)

const LOCAL_USER_ID = Players.LocalPlayer.UserId
const PROFILE_ICON = `rbxthumb://type=AvatarHeadShot&id={LOCAL_USER_ID}&w=150&h=150`

-- the topbar button opens the viewer's own profile, other menus can open anyone's through menu_navigation
const function player_profile_root()
	const menu_icon = use_topbar_menu_icon("Profile", PROFILE_ICON)
	const viewed_user_id, set_viewed_user_id = React.useState(LOCAL_USER_ID)
	-- names inside the formatted profile come from user_info_cache
	use_user_info_version()
	user_info_cache.request({ viewed_user_id })
	const viewed = use_viewed_player_profile(menu_icon.enabled, viewed_user_id)
	const actions = use_player_profile_actions(viewed_user_id)

	const function follow_navigation(): () -> ()
		const function navigate(destination: menu_navigation.destination): ()
			if destination.kind == "player_profile" then
				set_viewed_user_id(destination.user_id)
				menu_icon.open()
			else
				menu_icon.close()
			end
		end
		return menu_navigation.subscribe(navigate)
	end
	React.useEffect(follow_navigation, {})

	const function show_own_profile_when_closed(): ()
		if not menu_icon.enabled then
			set_viewed_user_id(LOCAL_USER_ID)
		end
	end
	React.useEffect(show_own_profile_when_closed, { menu_icon.enabled })

	return React.createElement(player_profile_menu, {
		enabled = menu_icon.enabled,
		on_close = menu_icon.close,
		profile = if viewed.snapshot then format_player_profile_snapshot(viewed.snapshot) else nil,
		failed = viewed.failed,
		viewer_is_self = viewed_user_id == LOCAL_USER_ID,
		actions = actions,
	})
end

return player_profile_root
