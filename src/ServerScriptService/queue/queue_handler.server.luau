const MessagingService = game:GetService("MessagingService")
const Players = game:GetService("Players")
const ReplicatedStorage = game:GetService("ReplicatedStorage")
const RunService = game:GetService("RunService")
const TeleportService = game:GetService("TeleportService")

const QUEUE_CONFIG = require(script.Parent.QUEUE_CONFIG)
const match_host = require(script.Parent.match_host)
const queue_lobby = require(script.Parent.queue_lobby)
const queue_record = require(script.Parent.queue_record)

const IS_RESERVED = game.PrivateServerId ~= "" and game.PrivateServerOwnerId == 0
const next_join: { [Player]: number } = {}

local function on_join(player: Player, requested_mode: unknown): boolean
	const mode: queue_record.mode? = queue_record.parse_mode(requested_mode)
	if RunService:IsStudio() or mode == nil or match_host.contains(player) or os.clock() < (next_join[player] or 0) then
		return false
	end
	next_join[player] = os.clock() + QUEUE_CONFIG.join_interval
	return queue_lobby.enqueue(player, mode)
end

local function on_leave(player: Player): boolean
	if not queue_lobby.leave(player) then
		return false
	end
	if IS_RESERVED then
		return match_host.leave(player)
	end
	return true
end

local function on_player_added(player: Player): ()
	if IS_RESERVED then
		task.spawn(match_host.accept, player)
	end
end

local function on_player_removing(player: Player): ()
	next_join[player] = nil
	queue_lobby.on_player_removing(player)
	match_host.on_player_removing(player)
end

local function on_ready(message: { Data: unknown }): ()
	const data = queue_record.as_dictionary(message.Data)
	const id = if data then data.id else nil
	if data == nil or typeof(id) ~= "string" then
		return
	end
	const mode: queue_record.mode? = queue_record.parse_mode(data.mode)
	if mode then
		queue_lobby.wake(mode, id)
	end
end

local function subscribe(): ()
	for attempt = 1, 3 do
		const ok, result = pcall(MessagingService.SubscribeAsync, MessagingService, QUEUE_CONFIG.ready_topic, on_ready)
		if ok then
			return
		end
		warn(result)
		task.wait(2 ^ attempt)
	end
end

local function run(): ()
	while true do
		queue_lobby.step()
		match_host.step()
		task.wait(1)
	end
end

ReplicatedStorage.remotes.join_queue.OnServerInvoke = on_join
ReplicatedStorage.remotes.leave_queue.OnServerInvoke = on_leave

-- Studio cannot perform live teleports
if RunService:IsStudio() then
	return
end

Players.PlayerAdded:Connect(on_player_added)
Players.PlayerRemoving:Connect(on_player_removing)
TeleportService.TeleportInitFailed:Connect(queue_lobby.on_teleport_failed)
for _, player in Players:GetPlayers() do
	on_player_added(player)
end

task.spawn(subscribe)
task.spawn(run)
