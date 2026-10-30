const HttpService = game:GetService("HttpService")
const MessagingService = game:GetService("MessagingService")
const Players = game:GetService("Players")
const TeleportService = game:GetService("TeleportService")

const QUEUE_CONFIG = require(script.Parent.QUEUE_CONFIG)
const queue_record = require(script.Parent.queue_record)
const queue_store = require(script.Parent.queue_store)

type mode = queue_record.mode
type record = queue_record.record
type ticket = {
	player: Player,
	id: string,
	mode: mode,
	token: string,
	teleporting: boolean,
	attempts: number,
	retry_at: number,
}
type group = {
	id: string,
	mode: mode,
	tickets: { [Player]: ticket },
	busy: boolean,
	next_poll: number,
	last_heartbeat: number,
}

const joining: { [Player]: string } = {}
const pending: { [Player]: ticket } = {}
const groups: { [string]: group } = {}

local function publish_ready(entry: record): ()
	pcall(MessagingService.PublishAsync, MessagingService, QUEUE_CONFIG.ready_topic, {
		id = entry.id,
		mode = entry.mode,
	})
end

local function forget(ticket: ticket): ()
	if pending[ticket.player] ~= ticket then
		return
	end
	pending[ticket.player] = nil
	const group = groups[ticket.id]
	if group then
		group.tickets[ticket.player] = nil
		if next(group.tickets) == nil then
			groups[ticket.id] = nil
		end
	end
end

local function enqueue(player: Player, mode: mode): boolean
	if joining[player] or pending[player] or player.Parent ~= Players then
		return false
	end
	const token = HttpService:GenerateGUID(false)
	joining[player] = token
	const candidates = queue_store.find(mode)
	if not candidates.ok then
		if joining[player] == token then
			joining[player] = nil
		end
		return false
	end
	const new_id = HttpService:GenerateGUID(false)
	local selected: record? = nil
	-- The final candidate creates an entry only after existing matches have been tried.
	for index = 1, #candidates.entries + 1 do
		if joining[player] ~= token or player.Parent ~= Players then
			break
		end
		const candidate = candidates.entries[index]
		const id = if candidate then candidate.id else new_id
		local function claim_slot(entry: record?): record?
			if joining[player] ~= token then
				return nil
			end
			if entry == nil then
				if id ~= new_id then
					return nil
				end
				entry = queue_record.create(id, mode, game.MatchmakingType.Value)
			end
			assert(entry)
			if entry.matchmaking_type ~= game.MatchmakingType.Value then
				return nil
			end
			if not queue_record.claim(entry, player.UserId, token, game.JobId, os.time()) then
				return nil
			end
			return entry
		end
		const result = queue_store.update(mode, id, claim_slot)
		if not result.ok then
			-- A failed response can still follow a committed write; release this exact token.
			task.spawn(queue_store.release, mode, id, player.UserId, token)
			break
		end
		if result.entry then
			selected = result.entry
			break
		end
	end
	if joining[player] ~= token or player.Parent ~= Players then
		if selected then
			task.spawn(queue_store.release, mode, selected.id, player.UserId, token)
		end
		return false
	end
	joining[player] = nil
	if selected == nil then
		return false
	end
	const ticket: ticket = {
		player = player,
		id = selected.id,
		mode = mode,
		token = token,
		teleporting = false,
		attempts = 0,
		retry_at = 0,
	}
	pending[player] = ticket
	local group = groups[selected.id]
	if group == nil then
		group = {
			id = selected.id,
			mode = mode,
			tickets = {},
			busy = false,
			next_poll = 0,
			last_heartbeat = os.time(),
		}
		groups[selected.id] = group
	end
	group.tickets[player] = ticket
	group.next_poll = 0
	if selected.status == "ready" then
		task.spawn(publish_ready, selected)
	end
	return true
end

local function teleport_player(ticket: ticket): ()
	if pending[ticket.player] ~= ticket or ticket.player.Parent ~= Players or ticket.teleporting then
		return
	end
	ticket.teleporting = true
	ticket.attempts += 1
	const options = Instance.new("TeleportOptions")
	options.ReservedServerId = ticket.id
	options:SetTeleportData({
		queue_match_id = ticket.id,
		queue_mode = ticket.mode,
		queue_token = ticket.token,
		queue_attempt = ticket.attempts,
	})
	const ok, failure = pcall(TeleportService.TeleportAsync, TeleportService, game.PlaceId, { ticket.player }, options)
	if not ok and pending[ticket.player] == ticket then
		ticket.teleporting = false
		ticket.retry_at = os.time() + 2 ^ ticket.attempts
		warn(failure)
	end
end

local function refresh_group(group: group): ()
	local result = queue_store.get(group.mode, group.id)
	const now = os.time()
	if result.ok and result.entry and now - group.last_heartbeat >= QUEUE_CONFIG.heartbeat_interval then
		const tokens: { [string]: string } = {}
		for player, ticket in group.tickets do
			if player.Parent == Players then
				tokens[tostring(player.UserId)] = ticket.token
			end
		end
		local function renew_slots(entry: record?): record?
			if entry then
				queue_record.renew(entry, tokens, os.time())
			end
			return entry
		end
		result = queue_store.update(group.mode, group.id, renew_slots)
		if result.ok then
			group.last_heartbeat = now
		end
	end
	if result.ok then
		const entry = result.entry
		if entry then
			queue_record.prune(entry, now)
		end
		for player, ticket in group.tickets do
			const member = if entry then queue_record.find_member(entry, player.UserId) else nil
			if entry and entry.status == "started" then
				forget(ticket)
			elseif entry == nil or entry.status == "cancelled" or member == nil or member.token ~= ticket.token then
				if not ticket.teleporting then
					forget(ticket)
					task.spawn(queue_store.release, ticket.mode, ticket.id, player.UserId, ticket.token)
					task.spawn(enqueue, player, ticket.mode)
				end
			elseif entry.status == "ready" and not ticket.teleporting and now >= ticket.retry_at then
				if ticket.attempts >= QUEUE_CONFIG.teleport_attempts then
					forget(ticket)
					task.spawn(queue_store.release, ticket.mode, ticket.id, player.UserId, ticket.token)
				else
					-- Mark synchronously before scheduling to prevent two notifications teleporting twice.
					ticket.teleporting = true
					local function send_player(): ()
						ticket.teleporting = false
						teleport_player(ticket)
					end
					task.spawn(send_player)
				end
			end
		end
	end
	group.next_poll = os.time() + QUEUE_CONFIG.poll_interval
	group.busy = false
end

local function step(): ()
	for _, group in groups do
		if not group.busy and os.time() >= group.next_poll then
			group.busy = true
			task.spawn(refresh_group, group)
		end
	end
end

local function wake(mode: mode, id: string): ()
	const group = groups[id]
	if group and group.mode == mode then
		group.next_poll = 0
	end
end

local function leave(player: Player): boolean
	const ticket = pending[player]
	if ticket and ticket.teleporting then
		return false
	end
	joining[player] = nil
	if ticket then
		forget(ticket)
		task.spawn(queue_store.release, ticket.mode, ticket.id, player.UserId, ticket.token)
	end
	return true
end

local function on_player_removing(player: Player): ()
	joining[player] = nil
	const ticket = pending[player]
	if ticket then
		forget(ticket)
		-- A successful teleport also removes the player; their destination renews the claim.
		if not ticket.teleporting then
			task.spawn(queue_store.release, ticket.mode, ticket.id, player.UserId, ticket.token)
		end
	end
end

local function on_teleport_failed(
	player: Player,
	_result: Enum.TeleportResult,
	failure: string,
	place_id: number,
	options: TeleportOptions
): ()
	const ticket = pending[player]
	const data = queue_record.as_dictionary(options:GetTeleportData())
	if
		ticket == nil
		or place_id ~= game.PlaceId
		or data == nil
		or data.queue_token ~= ticket.token
		or data.queue_match_id ~= ticket.id
		or data.queue_attempt ~= ticket.attempts
	then
		return
	end
	ticket.teleporting = false
	ticket.retry_at = os.time() + 2 ^ ticket.attempts
	warn(failure)
end

return {
	enqueue = enqueue,
	leave = leave,
	on_player_removing = on_player_removing,
	on_teleport_failed = on_teleport_failed,
	step = step,
	wake = wake,
}
