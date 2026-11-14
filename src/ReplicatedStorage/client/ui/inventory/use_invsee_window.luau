local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.react)
const inventory_state = require(script.Parent.inventory_state)
const invsee_state = require(ReplicatedStorage.client.inventory.invsee.invsee_state)
const invsee_util = require(ReplicatedStorage.client.inventory.invsee.invsee_util)

const function increment(current: number): number
	return current + 1
end

-- Ties invsee to the inventory window: a new target opens it, and closing it ends the session.
-- Returns the player whose inventory is open, and renders again whenever that inventory changes.
const function use_invsee_window(): Player?
	local target: Player?, set_target: (Player?) -> () = React.useState(invsee_util.get_target())
	local _, set_version = React.useState(0)

	const function subscribe()
		local previous_target = invsee_util.get_target()

		const function on_invsee_change(): ()
			const new_target = invsee_util.get_target()
			set_version(increment)
			if new_target == previous_target then
				return
			end
			previous_target = new_target
			set_target(new_target)
			-- last, because another menu can refuse the window, which ends the session and runs this again
			inventory_state.set_enabled(new_target ~= nil)
		end

		const function on_window_change(): ()
			if not inventory_state.enabled then
				invsee_util.stop()
			end
		end

		local connection_invsee = invsee_state.on_change:Connect(on_invsee_change)
		local connection_window = inventory_state.on_change:Connect(on_window_change)

		const function disconnect(): ()
			connection_invsee:Disconnect()
			connection_window:Disconnect()
		end

		return disconnect
	end

	React.useEffect(subscribe, {})

	return target
end

return use_invsee_window
