const profile_types = require(script.Parent.Parent.profile_types)

export type normalized_rank_history = {
	-- 0 to 1 on both axes, the best rank sits at the top so y is 0
	points: { Vector2 },
	best_rank: number,
	worst_rank: number,
	first_time: number,
	last_time: number,
}

const function normalize_rank_history(history: { profile_types.rank_point }): normalized_rank_history
	assert(#history > 0, "rank history needs at least one point")
	local best_rank, worst_rank = math.huge, -math.huge
	local first_time, last_time = math.huge, -math.huge
	for _, point in history do
		best_rank = math.min(best_rank, point.rank)
		worst_rank = math.max(worst_rank, point.rank)
		first_time = math.min(first_time, point.time)
		last_time = math.max(last_time, point.time)
	end
	const rank_span = worst_rank - best_rank
	const time_span = last_time - first_time
	const points = table.create(#history)
	for index, point in history do
		points[index] = Vector2.new(
			if time_span > 0 then (point.time - first_time) / time_span else 1,
			if rank_span > 0 then (point.rank - best_rank) / rank_span else 0.5
		)
	end
	return {
		points = points,
		best_rank = best_rank,
		worst_rank = worst_rank,
		first_time = first_time,
		last_time = last_time,
	}
end

return normalize_rank_history
