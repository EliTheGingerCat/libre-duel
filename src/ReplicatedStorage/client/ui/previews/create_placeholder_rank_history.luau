const profile_types = require(script.Parent.Parent.profile_card.profile_types)

const SECONDS_PER_DAY = 86400

-- one point per day, ending today
const function create_placeholder_rank_history(ranks: { number }): { profile_types.rank_point }
	const now = os.time()
	const history = table.create(#ranks)
	for index, rank in ranks do
		history[index] = { time = now - (#ranks - index) * SECONDS_PER_DAY, rank = rank }
	end
	return history
end

return create_placeholder_rank_history
