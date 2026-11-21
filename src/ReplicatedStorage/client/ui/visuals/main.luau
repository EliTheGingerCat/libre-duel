local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.react)
local large_notification_container = require(script.Parent.Parent.large_notification.large_notification_container)
local component_showcase = require(script.Parent.components_showcase)
local crosshair = require(script.Parent.crosshair)
local gameplay_hud = require(script.Parent.gameplay_hud)
const guild_menu_controller = require(script.Parent.Parent.guild.guild_menu_controller)
local guild_menu_preview = require(script.Parent.Parent.previews.guild_menu_preview)
local hotbar = require(script.Parent.hotbar)
local infoboard = require(script.Parent.infoboard)
local inventory = require(script.Parent.Parent.inventory.inventory)
local matchmaking = require(script.Parent.matchmaking)
local notification_container = require(script.Parent.notification_container)
local player_profile_preview = require(script.Parent.Parent.previews.player_profile_preview)
local settings = require(script.Parent.Parent.settings.settings)
local tablist = require(script.Parent.tablist)
local title = require(script.Parent.title)
local version = require(script.Parent.version)

local create_element = React.createElement

const function main()
	return create_element(
		React.Fragment,
		{},
		create_element(large_notification_container),
		create_element(component_showcase),
		create_element(crosshair),
		create_element(gameplay_hud),
		create_element(guild_menu_controller),
		create_element(guild_menu_preview),
		create_element(hotbar),
		create_element(infoboard),
		create_element(inventory),
		create_element(matchmaking),
		create_element(notification_container),
		create_element(player_profile_preview),
		create_element(settings),
		create_element(tablist),
		create_element(title),
		create_element(version)
	)
end

return main
