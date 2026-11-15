const ReplicatedStorage = game:GetService("ReplicatedStorage")

const chrono = require(ReplicatedStorage.Packages.chrono)

-- the wally link module doesn't re-export chrono's types, so only the parts used here are spelled out
type history = {
	Push: (self: history, time: number, value: CFrame, velocity: Vector3) -> (),
	GetLatest: (self: history) -> { t: number, value: CFrame, velocity: Vector3 }?,
	GetAt: (self: history, time: number) -> CFrame?,
}

-- keyed by the owning client's chrono clock, which is the same clock every other client renders that player on
const histories: { [Player]: history } = {}

-- clients interpolate with hermite, linear is close enough for a hitbox at chrono's tick rate
const function lerp_position(
	start_position: Vector3,
	end_position: Vector3,
	_start_velocity: Vector3,
	_end_velocity: Vector3,
	alpha: number,
	_delta_time: number
): Vector3
	return start_position:Lerp(end_position, alpha)
end

-- created lazily since chrono only sizes snapshot buffers after it has started
const function get_or_create_history(player: Player): history
	const existing_history = histories[player]
	if existing_history then
		return existing_history
	end
	const new_history: history = chrono.Snapshots(lerp_position)
	histories[player] = new_history
	return new_history
end

const function record(player: Player, client_time: number, root_cframe: CFrame): ()
	get_or_create_history(player):Push(client_time, root_cframe, Vector3.zero)
end

const function get_latest_time(player: Player): number?
	const history = histories[player]
	if history == nil then
		return nil
	end
	const latest = history:GetLatest()
	return if latest then latest.t else nil
end

const function get_root_cframe_at(player: Player, client_time: number): CFrame?
	const history = histories[player]
	if history == nil then
		return nil
	end
	return history:GetAt(client_time)
end

const function clear(player: Player): ()
	histories[player] = nil
end

return {
	clear = clear,
	get_latest_time = get_latest_time,
	get_root_cframe_at = get_root_cframe_at,
	record = record,
}
