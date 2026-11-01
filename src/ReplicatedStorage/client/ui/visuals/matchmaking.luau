local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.react)
local mode_selector = require(script.Parent.Parent.matchmaking.mode_selector)
local queue_status = require(script.Parent.Parent.matchmaking.queue_status)

local function matchmaking()
	return React.createElement(React.Fragment, {}, {
		mode_selector = React.createElement(mode_selector),
		queue_status = React.createElement(queue_status),
	})
end

return matchmaking
