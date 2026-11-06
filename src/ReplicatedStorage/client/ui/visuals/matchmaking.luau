local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.react)
local mode_selector = require(script.Parent.Parent.matchmaking.mode_selector)
local play_button = require(script.Parent.Parent.matchmaking.play_button)
local queue_status = require(script.Parent.Parent.matchmaking.queue_status)

local function matchmaking()
	return React.createElement(React.Fragment, {}, {
		mode_selector = React.createElement(mode_selector),
		play_button = React.createElement(play_button),
		queue_status = React.createElement(queue_status),
	})
end

return matchmaking
