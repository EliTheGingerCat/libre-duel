const ReplicatedStorage = game:GetService("ReplicatedStorage")
const RunService = game:GetService("RunService")
const UserInputService = game:GetService("UserInputService")

const React = require(ReplicatedStorage.Packages.react)

const function invert_enabled(current: boolean): boolean
	return not current
end

-- opens and closes a menu with a key, only in Studio, for menus that have no real way to open them yet
const function use_studio_preview_toggle(key: Enum.KeyCode): (boolean, (boolean) -> ())
	const enabled, set_enabled = React.useState(false)
	const function track_key(): (() -> ())?
		if not RunService:IsStudio() then
			return nil
		end
		const function toggle(input: InputObject, processed: boolean): ()
			if not processed and input.KeyCode == key then
				set_enabled(invert_enabled)
			end
		end
		const connection = UserInputService.InputBegan:Connect(toggle)
		const function disconnect(): ()
			connection:Disconnect()
		end
		return disconnect
	end
	React.useEffect(track_key, {})
	return enabled, set_enabled
end

return use_studio_preview_toggle
