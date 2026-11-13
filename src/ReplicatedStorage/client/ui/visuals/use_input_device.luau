const ReplicatedStorage = game:GetService("ReplicatedStorage")

const React = require(ReplicatedStorage.Packages.react)
const input_device = require(ReplicatedStorage.client.util.input_device)

const function use_input_device(): input_device.device
	const device, set_device = React.useState(input_device.current)

	const function subscribe_device(): () -> ()
		const connection = input_device.changed:Connect(set_device)
		set_device(input_device.current)

		const function disconnect(): ()
			connection:Disconnect()
		end

		return disconnect
	end
	React.useEffect(subscribe_device, {})

	return device
end

return use_input_device
