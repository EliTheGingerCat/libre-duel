const character_history = require(script.Parent.character_history)
const LAG_COMPENSATION_CONSTANTS = require(script.Parent.LAG_COMPENSATION_CONSTANTS)

-- GetNetworkPing is measured by the server, so a client can only widen this window by actually lagging,
-- and it's doubled so it covers the round trip whether or not GetNetworkPing already counts both ways
const function get_allowed_rewind_seconds(attacker: Player): number
	const round_trip_allowance = math.max(attacker:GetNetworkPing(), 0) * 2
	return math.min(
		round_trip_allowance + LAG_COMPENSATION_CONSTANTS.interpolation_buffer_allowance_seconds,
		LAG_COMPENSATION_CONSTANTS.maximum_rewind_seconds
	)
end

-- where the target's root was on the attacker's screen, clamped so a lying client can't reach further into the past
const function get_rewound_root_cframe(attacker: Player, target: Player, claimed_render_time: number?): CFrame?
	const latest_time = character_history.get_latest_time(target)
	if latest_time == nil or claimed_render_time == nil then
		return nil
	end
	const render_time = math.clamp(claimed_render_time, latest_time - get_allowed_rewind_seconds(attacker), latest_time)
	return character_history.get_root_cframe_at(target, render_time)
end

return get_rewound_root_cframe
