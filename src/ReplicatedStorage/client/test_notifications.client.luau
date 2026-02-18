local RunService = game:GetService("RunService")

local notification_management = require(script.Parent.modules.notification_management)

-- Manually change this to enable. Should always be disabled in the official repository, so if this variable is changed, avoid staging that change to Git. However, this can get annoying. Perhaps it should be managed by a chat command, a keybind, or the like.
local enabled = false

if RunService:IsStudio() and enabled then
	local words = {"Hi!", "Hello!"}

	local function thread_notification(): ()
		while true do
			notification_management.add(words[math.random(1, #words)])
			task.wait(math.random(0.3, 2))
		end
	end

	task.spawn(thread_notification)
end
