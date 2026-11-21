const ReplicatedStorage = game:GetService("ReplicatedStorage")

const GAME_STATS = require(ReplicatedStorage.shared.modes.GAME_STATS)

-- stats created at runtime miss modes added after they were saved, this fills them from GAME_STATS
-- always returns fresh tables so the result can be edited even when the input is frozen
const function normalize_mode_stats(stats: GAME_STATS.modes?): GAME_STATS.modes
	const normalized: GAME_STATS.modes = {}
	for mode: GAME_STATS.mode, default_stats in GAME_STATS do
		const saved = if stats then stats[mode] else nil
		const mode_stats = table.clone(default_stats)
		if saved then
			for stat, value in saved do
				mode_stats[stat] = value
			end
		end
		normalized[mode] = mode_stats
	end
	return normalized
end

return normalize_mode_stats
