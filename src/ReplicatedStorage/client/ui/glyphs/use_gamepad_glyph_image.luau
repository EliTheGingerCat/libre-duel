const ReplicatedStorage = game:GetService("ReplicatedStorage")
const UserInputService = game:GetService("UserInputService")

const React = require(ReplicatedStorage.Packages.react)
const input_device = require(ReplicatedStorage.client.util.input_device)

-- the image follows the connected controller (xbox, playstation, ...), so it is read again whenever that may change
-- `key_code` must be constant
const function use_gamepad_glyph_image(key_code: Enum.KeyCode): string
	const function read_glyph_image(): string
		return UserInputService:GetImageForKeyCode(key_code)
	end

	const glyph_image, set_glyph_image = React.useState(read_glyph_image)

	const function subscribe_glyph_image()
		const function refresh_glyph_image(): ()
			set_glyph_image(read_glyph_image())
		end

		const connection_gamepad_connected = UserInputService.GamepadConnected:Connect(refresh_glyph_image)
		const connection_gamepad_disconnected = UserInputService.GamepadDisconnected:Connect(refresh_glyph_image)
		const connection_device_changed = input_device.changed:Connect(refresh_glyph_image)

		const function disconnect(): ()
			connection_gamepad_connected:Disconnect()
			connection_gamepad_disconnected:Disconnect()
			connection_device_changed:Disconnect()
		end

		return disconnect
	end
	React.useEffect(subscribe_glyph_image, {})

	return glyph_image
end

return use_gamepad_glyph_image
