const Players = game:GetService("Players")
const ReplicatedStorage = game:GetService("ReplicatedStorage")

const chrono = require(ReplicatedStorage.Packages.chrono)
const ENTITY_RANGE = require(ReplicatedStorage.shared.combat.ENTITY_RANGE)
const get_entity_position = require(ReplicatedStorage.shared.entity.get_entity_position)
const melee_swing_types = require(ReplicatedStorage.shared.combat.melee_swing_types)

-- players further than this can't be swung at, so they're left out to keep the packet small
const CANDIDATE_RANGE = ENTITY_RANGE * 3

const local_player = Players.LocalPlayer

-- chrono renders every player on that player's own clock, so each target gets its own render time
const function get_target_render_times(): { melee_swing_types.render_time_entry }
	const entries: { melee_swing_types.render_time_entry } = {}
	const local_position = get_entity_position(local_player)
	if local_position == nil then
		return entries
	end

	for _, player in Players:GetPlayers() do
		if player == local_player then
			continue
		end
		const target_position = get_entity_position(player)
		if target_position == nil or (target_position - local_position).Magnitude > CANDIDATE_RANGE then
			continue
		end
		const entity = chrono.Holder.GetEntityFromPlayer(player)
		if entity == nil then
			continue
		end
		-- chrono reports 0 or -1 before it has synced that player's clock
		const render_time = chrono.Entity.GetTargetRenderTime(entity)
		if render_time > 0 then
			table.insert(entries, { player = player, time = render_time })
		end
	end

	return entries
end

return get_target_render_times
