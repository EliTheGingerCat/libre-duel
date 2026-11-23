local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.react)
local large_notification_container = require(script.Parent.large_notification.large_notification_container)
local component_showcase = require(script.Parent.components.components_showcase)
local crosshair = require(script.Parent.crosshair.crosshair)
local gameplay_hud = require(script.Parent.hud.gameplay_hud)
local guild_menu_preview = require(script.Parent.previews.guild_menu_preview)
const guild_menu_root = require(script.Parent.guild.guild_menu_root)
local hotbar = require(script.Parent.hotbar.hotbar)
local infoboard = require(script.Parent.infoboard.infoboard)
local inventory = require(script.Parent.inventory.inventory)
local matchmaking = require(script.Parent.matchmaking.matchmaking)
local notification_container = require(script.Parent.notification.notification_container)
const popup_container = require(script.Parent.popup.popup_container)
local player_profile_preview = require(script.Parent.previews.player_profile_preview)
const player_profile_root = require(script.Parent.player_profile.player_profile_root)
local settings = require(script.Parent.settings.settings)
local tablist = require(script.Parent.tablist.tablist)
local title = require(script.Parent.title.title)
local version = require(script.Parent.version.version)

local create_element = React.createElement

const function main()
	return create_element(
		React.Fragment,
		{},
		create_element(large_notification_container),
		create_element(component_showcase),
		create_element(crosshair),
		create_element(gameplay_hud),
		create_element(guild_menu_root),
		create_element(guild_menu_preview),
		create_element(hotbar),
		create_element(infoboard),
		create_element(inventory),
		create_element(matchmaking),
		create_element(notification_container),
		create_element(player_profile_preview),
		create_element(player_profile_root),
		create_element(popup_container),
		create_element(settings),
		create_element(tablist),
		create_element(title),
		create_element(version)
	)
end

return main
