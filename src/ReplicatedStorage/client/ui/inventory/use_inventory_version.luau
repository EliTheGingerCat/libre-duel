local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.react)
local client_inventory_util = require(ReplicatedStorage.client.inventory.client_inventory_util)

const function increment(current: number): number
	return current + 1
end

-- The inventory is mutated in place, so bump a counter to render again on every change.
const function use_inventory_version(): number
	local version, set_version = React.useState(0)

	const function subscribe()
		const function on_change(): ()
			set_version(increment)
		end

		local connection = client_inventory_util.on_change:Connect(on_change)

		const function disconnect(): ()
			connection:Disconnect()
		end

		return disconnect
	end

	React.useEffect(subscribe, {})

	return version
end

return use_inventory_version
