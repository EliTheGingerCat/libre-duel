const Players = game:GetService("Players")
const TeleportService = game:GetService("TeleportService")

const QUEUE_CONFIG = require(script.Parent.QUEUE_CONFIG)
const match_session = require(script.Parent.match_session)
const queue_lobby = require(script.Parent.queue_lobby)
const queue_record = require(script.Parent.queue_record)
const queue_store = require(script.Parent.queue_store)

type record = queue_record.record
type context = {
	id: string,
	mode: queue_record.mode,
	players: { [Player]: string },
	started: boolean,
	busy: boolean,
	next_poll: number,
	last_heartbeat: number,
}

const validating: { [Player]: boolean } = {}
local current: context? = nil

local function all_present(context: context, entry: record): boolean
	const settings = QUEUE_CONFIG.modes[entry.mode]
	if queue_record.count_members(entry) ~= settings.teams * settings.entities_per_team then
		return false
	end
	for _, members in entry.teams do
		for _, member in members do
			const player = Players:GetPlayerByUserId(member.user_id)
			if player == nil or player.Parent ~= Players or context.players[player] ~= member.token then
				return false
			end
		end
	end
	return true
end

local function requeue(context: context): ()
	if current ~= context then
		return
	end
	current = nil
	local function cancel_match(entry: record?): record?
		if entry and entry.destination_job_id == game.JobId then
			entry.status = "cancelled"
			return entry
		end
		return nil
	end
	queue_store.update(context.mode, context.id, cancel_match)
	for player in context.players do
		task.spawn(queue_lobby.enqueue, player, context.mode)
	end
end

local function accept(player: Player): ()
	validating[player] = true
	const join_data = player:GetJoinData()
	const data = queue_record.as_dictionary(join_data.TeleportData)
	const id = if data then data.queue_match_id else nil
	const token = if data then data.queue_token else nil
	if
		join_data.SourceGameId ~= game.GameId
		or data == nil
		or typeof(id) ~= "string"
		or typeof(token) ~= "string"
	then
		validating[player] = nil
		player:Kick("This match is no longer available.")
		return
	end
	const mode: queue_record.mode? = queue_record.parse_mode(data.queue_mode)
	if mode == nil then
		validating[player] = nil
		player:Kick("This match is no longer available.")
		return
	end
	local function confirm_arrival(entry: record?): record?
		if entry == nil or player.Parent ~= Players then
			return nil
		end
		queue_record.prune(entry, os.time())
		const member = queue_record.find_member(entry, player.UserId)
		if
			entry.status ~= "ready"
			or entry.matchmaking_type ~= game.MatchmakingType.Value
			or member == nil
			or member.token ~= token
			or (entry.destination_job_id ~= "" and entry.destination_job_id ~= game.JobId)
		then
			return nil
		end
		entry.destination_job_id = game.JobId
		member.expires_at = os.time() + QUEUE_CONFIG.slot_lifetime
		return entry
	end
	local result = queue_store.update(mode, id, confirm_arrival)
	for attempt = 1, 2 do
		if result.ok or player.Parent ~= Players then
			break
		end
		task.wait(2 ^ attempt)
		result = queue_store.update(mode, id, confirm_arrival)
	end
	validating[player] = nil
	if player.Parent ~= Players then
		task.spawn(queue_store.release, mode, id, player.UserId, token)
		return
	end
	if not result.ok then
		player:Kick("Matchmaking is unavailable. Please rejoin.")
		return
	end
	if result.entry == nil then
		task.spawn(queue_lobby.enqueue, player, mode)
		return
	end
	local context = current
	if context == nil then
		context = {
			id = id,
			mode = mode,
			players = {},
			started = false,
			busy = false,
			next_poll = 0,
			last_heartbeat = os.time(),
		}
		current = context
	end
	assert(context)
	if context.id ~= id or context.mode ~= mode or context.started then
		player:Kick("This match is no longer available.")
		return
	end
	context.players[player] = token
	context.next_poll = 0
end

local function refresh(context: context): ()
	local result = queue_store.get(context.mode, context.id)
	if result.ok and result.entry and os.time() - context.last_heartbeat >= QUEUE_CONFIG.heartbeat_interval then
		const tokens: { [string]: string } = {}
		for player, token in context.players do
			if player.Parent == Players then
				tokens[tostring(player.UserId)] = token
			end
		end
		local function renew_arrivals(entry: record?): record?
			if entry and entry.destination_job_id == game.JobId then
				queue_record.renew(entry, tokens, os.time())
				return entry
			end
			return nil
		end
		result = queue_store.update(context.mode, context.id, renew_arrivals)
		if result.ok then
			context.last_heartbeat = os.time()
		end
	end
	if result.ok and current == context then
		const entry = result.entry
		if entry then
			queue_record.prune(entry, os.time())
		end
		if entry == nil or (entry.status ~= "ready" and entry.status ~= "started") then
			requeue(context)
		elseif all_present(context, entry) then
			local function start_match(latest: record?): record?
				if latest == nil or current ~= context then
					return nil
				end
				queue_record.prune(latest, os.time())
				if
					(latest.status ~= "ready" and latest.status ~= "started")
					or latest.destination_job_id ~= game.JobId
					or not all_present(context, latest)
				then
					return nil
				end
				latest.status = "started"
				return latest
			end
			const started = queue_store.update(context.mode, context.id, start_match)
			const started_entry = started.entry
			if started.ok and started_entry and current == context then
				if all_present(context, started_entry) then
					const roster: match_session.roster = {}
					for team_name, members in started_entry.teams do
						const user_ids: { number } = {}
						for _, member in members do
							table.insert(user_ids, member.user_id)
						end
						roster[team_name] = user_ids
					end
					context.started = true
					match_session.start(roster)
				else
					requeue(context)
				end
			end
		elseif entry.status == "started" then
			-- Recover a committed start whose response was lost, without starting a partial roster.
			requeue(context)
		end
	end
	context.next_poll = os.time() + QUEUE_CONFIG.poll_interval
	context.busy = false
end

local function step(): ()
	const context = current
	if context and not context.started and not context.busy and os.time() >= context.next_poll then
		context.busy = true
		task.spawn(refresh, context)
	end
end

local function contains(player: Player): boolean
	return validating[player] == true or (current ~= nil and current.players[player] ~= nil)
end

local function on_player_removing(player: Player): ()
	validating[player] = nil
	const context = current
	if context then
		const token = context.players[player]
		context.players[player] = nil
		if token and not context.started then
			task.spawn(queue_store.release, context.mode, context.id, player.UserId, token)
		end
	end
end

local function leave(player: Player): boolean
	if validating[player] or (current and current.started) then
		return false
	end
	on_player_removing(player)
	const options = Instance.new("TeleportOptions")
	options:SetTeleportData({ skip_queue = true })
	const ok, failure = pcall(TeleportService.TeleportAsync, TeleportService, game.PlaceId, { player }, options)
	if not ok then
		warn(failure)
	end
	return ok
end

local function on_finished(): ()
	current = nil
end

match_session.finished:Connect(on_finished)

return {
	accept = accept,
	contains = contains,
	leave = leave,
	on_player_removing = on_player_removing,
	step = step,
}
