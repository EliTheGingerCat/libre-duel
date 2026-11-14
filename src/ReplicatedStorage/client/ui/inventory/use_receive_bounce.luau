const GuiService = game:GetService("GuiService")
const ReplicatedStorage = game:GetService("ReplicatedStorage")
const RunService = game:GetService("RunService")

local React = require(ReplicatedStorage.Packages.react)
const item_received = require(ReplicatedStorage.client.inventory.received.item_received)
const scale_animation_time = require(script.Parent.Parent.effects.scale_animation_time)

const DURATION = 0.45
const AMPLITUDE = 0.35
const DAMPING = 6
const WOBBLES = 2.5

const function get_bounce_scale(progress: number): number
	return 1 + AMPLITUDE * math.exp(-DAMPING * progress) * math.sin(progress * math.pi * WOBBLES)
end

-- Returns a scale binding that bounces whenever `inventory_slot` receives items. nil never bounces.
const function use_receive_bounce(inventory_slot: number?)
	local bounce_scale, set_bounce_scale = React.useBinding(1)

	const function subscribe()
		if inventory_slot == nil then
			return
		end
		local render_connection: RBXScriptConnection? = nil

		const function stop_bounce(): ()
			if render_connection ~= nil then
				render_connection:Disconnect()
				render_connection = nil
			end
			set_bounce_scale(1)
		end

		const function on_receive(received_slot: number): ()
			const duration = scale_animation_time(DURATION)
			if received_slot ~= inventory_slot or GuiService.ReducedMotionEnabled or duration == 0 then
				return
			end
			stop_bounce()
			const started_at = os.clock()

			const function step(): ()
				const progress = (os.clock() - started_at) / duration
				if progress >= 1 then
					stop_bounce()
					return
				end
				set_bounce_scale(get_bounce_scale(progress))
			end

			render_connection = RunService.RenderStepped:Connect(step)
		end

		const receive_connection = item_received.on_receive:Connect(on_receive)

		const function disconnect(): ()
			receive_connection:Disconnect()
			stop_bounce()
		end

		return disconnect
	end

	React.useEffect(subscribe, { inventory_slot })

	return bounce_scale
end

return use_receive_bounce
