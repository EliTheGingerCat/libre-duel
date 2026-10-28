local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.react)
local component_showcase = require(script.Parent.components_showcase)
local crosshair = require(script.Parent.crosshair)
local gameplay_hud = require(script.Parent.gameplay_hud)
local hotbar = require(script.Parent.hotbar)
local infoboard = require(script.Parent.infoboard)
local notification_container = require(script.Parent.notification_container)
local tablist = require(script.Parent.tablist)
local version = require(script.Parent.version)

local create_element = React.createElement

local function main()
	return create_element(React.Fragment, {},
		create_element(component_showcase),
		create_element(crosshair),
		create_element(gameplay_hud),
		create_element(hotbar),
		create_element(infoboard),
		create_element(notification_container),
		create_element(tablist),
		create_element(version)
	)
end

return main
