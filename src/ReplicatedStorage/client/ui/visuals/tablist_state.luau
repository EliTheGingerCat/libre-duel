local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Signal = require(ReplicatedStorage.Packages.signal)

-- Pinned keeps the tablist open without holding its key, for devices with no keyboard.
local tablist_state = {
	pinned = false,
	on_change = Signal.new(),
}

local function set_pinned(pinned: boolean): ()
	if tablist_state.pinned == pinned then
		return
	end
	tablist_state.pinned = pinned
	tablist_state.on_change:Fire()
end

tablist_state.set_pinned = set_pinned

return tablist_state
