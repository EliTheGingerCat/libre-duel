local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Signal = require(ReplicatedStorage.Packages.signal)
local cursor_state = require(script.Parent.Parent.cursor_state)

local changed = Signal.new()
local requested = Signal.new()
local selector_requested = Signal.new()

local editor_state = {
	enabled = false,
}

local function set_enabled(enabled: boolean): ()
	if editor_state.enabled == enabled then
		return
	end
	editor_state.enabled = enabled
	cursor_state.set_free("hud_editor", enabled)
	changed:Fire()
end

local function subscribe(callback: () -> ())
	local connection = changed:Connect(callback)
	local function disconnect(): ()
		connection:Disconnect()
	end
	return disconnect
end

local function request_enabled(enabled: boolean): ()
	requested:Fire(enabled)
end

local function on_requested(callback: (boolean) -> ())
	local connection = requested:Connect(callback)
	local function disconnect(): ()
		connection:Disconnect()
	end
	return disconnect
end

local function request_selector(): ()
	selector_requested:Fire()
end

local function on_selector_requested(callback: () -> ())
	local connection = selector_requested:Connect(callback)
	local function disconnect(): ()
		connection:Disconnect()
	end
	return disconnect
end

editor_state.set_enabled = set_enabled
editor_state.subscribe = subscribe
editor_state.request_enabled = request_enabled
editor_state.on_requested = on_requested
editor_state.request_selector = request_selector
editor_state.on_selector_requested = on_selector_requested

return editor_state
