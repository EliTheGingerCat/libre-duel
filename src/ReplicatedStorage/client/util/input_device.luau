-- Which kind of device the player is using right now, as a plain string so new ones need no special casing.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Signal = require(ReplicatedStorage.Packages.signal)

export type device = string

const DEVICE_NAMES: { [Enum.PreferredInput]: device } = {
	[Enum.PreferredInput.KeyboardAndMouse] = "keyboard_mouse",
	[Enum.PreferredInput.Touch] = "touch",
	[Enum.PreferredInput.Gamepad] = "gamepad",
}

local function read_device(): device
	local preferred = UserInputService.PreferredInput
	return DEVICE_NAMES[preferred] or string.lower(preferred.Name)
end

local input_device = {
	current = read_device(),
	changed = Signal.new(),
}

-- `supported` being nil means every device is supported.
local function supports(supported: { device }?, device: device?): boolean
	return supported == nil or table.find(supported, device or input_device.current) ~= nil
end

local function update(): ()
	local device = read_device()
	if device == input_device.current then
		return
	end
	input_device.current = device
	input_device.changed:Fire(device)
end

UserInputService:GetPropertyChangedSignal("PreferredInput"):Connect(update)

input_device.supports = supports

return input_device
