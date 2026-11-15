const Players = game:GetService("Players")
const ReplicatedStorage = game:GetService("ReplicatedStorage")
const RunService = game:GetService("RunService")

const character_history = require(script.Parent.character_history)
const chrono = require(ReplicatedStorage.Packages.chrono)

-- only compared by identity, and the wally link module doesn't re-export chrono's entity type anyway
const recorded_entities: { [Player]: unknown } = {}
const recorded_times: { [Player]: number } = {}

const function forget_player(player: Player): ()
	recorded_entities[player] = nil
	recorded_times[player] = nil
	character_history.clear(player)
end

const function record_player(player: Player): ()
	const entity = chrono.Holder.GetEntityFromPlayer(player)
	if entity == nil then
		return
	end

	-- a respawn makes a new entity, and interpolating between two lives would drag the hitbox across the map
	if recorded_entities[player] ~= entity then
		forget_player(player)
		recorded_entities[player] = entity
	end

	const client_time = entity.lastClientClock
	const root_cframe = entity.latestCFrame
	if client_time == nil or root_cframe == nil or client_time == recorded_times[player] then
		return
	end

	recorded_times[player] = client_time
	character_history.record(player, client_time, root_cframe)
end

const function on_heartbeat(): ()
	for _, player in Players:GetPlayers() do
		record_player(player)
	end
end

RunService.Heartbeat:Connect(on_heartbeat)
Players.PlayerRemoving:Connect(forget_player)
