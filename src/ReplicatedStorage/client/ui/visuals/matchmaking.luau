local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.react)
local mount_mode_selector = require(script.Parent.Parent.matchmaking.mount_mode_selector)
local mount_queue_status = require(script.Parent.Parent.matchmaking.mount_queue_status)

local function matchmaking(): nil
	React.useEffect(mount_mode_selector, {})
	React.useEffect(mount_queue_status, {})
	return nil
end

return matchmaking
