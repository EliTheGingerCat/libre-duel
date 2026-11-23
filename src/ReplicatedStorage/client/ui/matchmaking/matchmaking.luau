local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.react)
local mode_selector = require(script.Parent.mode_selector)
local play_button = require(script.Parent.play_button)
local queue_status = require(script.Parent.queue_status)

const function matchmaking()
	return React.createElement(React.Fragment, {}, {
		mode_selector = React.createElement(mode_selector),
		play_button = React.createElement(play_button),
		queue_status = React.createElement(queue_status),
	})
end

return matchmaking
