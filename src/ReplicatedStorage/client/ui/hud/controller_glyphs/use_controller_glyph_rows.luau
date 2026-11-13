const ReplicatedStorage = game:GetService("ReplicatedStorage")
const RunService = game:GetService("RunService")

const React = require(ReplicatedStorage.Packages.react)
const controller_glyph_types = require(script.Parent.controller_glyph_types)
const get_controller_glyph_rows = require(script.Parent.get_controller_glyph_rows)
const input_device = require(ReplicatedStorage.client.util.input_device)
const read_controller_glyph_context = require(script.Parent.read_controller_glyph_context)

type controller_glyph_row = controller_glyph_types.controller_glyph_row

-- the hud editor preview has no live context, so it shows a typical fight
const PREVIEW_ROWS = get_controller_glyph_rows({
	menu = nil,
	play_available = false,
	attack_label = "Attack",
	use_label = "Block",
	sneak_relevant = false,
	hotbar_relevant = true,
})

const function get_rows_signature(rows: { controller_glyph_row }): string
	const labels = {}
	for _, row in rows do
		table.insert(labels, row.label)
	end
	return table.concat(labels, "\0")
end

const function use_controller_glyph_rows(preview: boolean?): { controller_glyph_row }
	const rows, set_rows = React.useState(PREVIEW_ROWS)
	const rows_signature = React.useRef(get_rows_signature(PREVIEW_ROWS))

	const function poll_rows(): (() -> ())?
		if preview then
			return nil
		end

		-- what's under the crosshair changes without any event, so this has to be polled
		const function on_heartbeat(): ()
			if input_device.current ~= "gamepad" then
				return
			end
			const rows_now = get_controller_glyph_rows(read_controller_glyph_context())
			const signature_now = get_rows_signature(rows_now)
			if signature_now ~= rows_signature.current then
				rows_signature.current = signature_now
				set_rows(rows_now)
			end
		end

		const connection = RunService.Heartbeat:Connect(on_heartbeat)
		on_heartbeat()

		const function disconnect(): ()
			connection:Disconnect()
		end

		return disconnect
	end
	React.useEffect(poll_rows, {})

	return rows
end

return use_controller_glyph_rows
