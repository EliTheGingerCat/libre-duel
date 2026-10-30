const QUEUE_CONFIG = require(script.Parent.QUEUE_CONFIG)

export type mode = "solo" | "duo"
export type status = "waiting" | "ready" | "started" | "cancelled"
export type member = {
	user_id: number,
	token: string,
	source_job_id: string,
	expires_at: number,
}
export type record = {
	id: string,
	mode: mode,
	matchmaking_type: number,
	status: status,
	teams: { [string]: { [string]: member } },
	arrival_deadline: number,
	destination_job_id: string,
}

local function parse_mode(value: unknown): mode?
	if value == "solo" then
		return "solo"
	elseif value == "duo" then
		return "duo"
	end
	return nil
end

local function as_dictionary(value: unknown): { [string]: unknown }?
	if typeof(value) ~= "table" then
		return nil
	end
	-- Only the container is known here; callers validate each field before using it.
	return value :: { [string]: unknown }
end

local function parse_member(value: unknown): member?
	const fields = as_dictionary(value)
	if fields == nil then
		return nil
	end
	const user_id = fields.user_id
	const token = fields.token
	const source_job_id = fields.source_job_id
	const expires_at = fields.expires_at
	if
		typeof(user_id) ~= "number"
		or typeof(token) ~= "string"
		or typeof(source_job_id) ~= "string"
		or typeof(expires_at) ~= "number"
	then
		return nil
	end
	return {
		user_id = user_id,
		token = token,
		source_job_id = source_job_id,
		expires_at = expires_at,
	}
end

local function decode(value: unknown): record?
	const fields = as_dictionary(value)
	if fields == nil then
		return nil
	end
	const mode: mode? = parse_mode(fields.mode)
	const status = fields.status
	const id = fields.id
	const matchmaking_type = fields.matchmaking_type
	const raw_teams = as_dictionary(fields.teams)
	const arrival_deadline = fields.arrival_deadline
	const destination_job_id = fields.destination_job_id
	if
		mode == nil
		or typeof(id) ~= "string"
		or typeof(matchmaking_type) ~= "number"
		or raw_teams == nil
		or typeof(arrival_deadline) ~= "number"
		or typeof(destination_job_id) ~= "string"
		or (status ~= "waiting" and status ~= "ready" and status ~= "started" and status ~= "cancelled")
	then
		return nil
	end
	const teams: { [string]: { [string]: member } } = {}
	const seen: { [string]: boolean } = {}
	const settings = QUEUE_CONFIG.modes[mode]
	for team_index = 1, settings.teams do
		const team_name = `team{team_index}`
		const raw_members = as_dictionary(raw_teams[team_name])
		if raw_members == nil then
			return nil
		end
		const members: { [string]: member } = {}
		local size = 0
		for user_key, raw_member in raw_members do
			const member = parse_member(raw_member)
			if typeof(user_key) ~= "string" or member == nil or user_key ~= tostring(member.user_id) or seen[user_key] then
				return nil
			end
			members[user_key] = member
			seen[user_key] = true
			size += 1
		end
		if size > settings.entities_per_team then
			return nil
		end
		teams[team_name] = members
	end
	return {
		id = id,
		mode = mode,
		matchmaking_type = matchmaking_type,
		status = status,
		teams = teams,
		arrival_deadline = arrival_deadline,
		destination_job_id = destination_job_id,
	}
end

local function create(id: string, mode: mode, matchmaking_type: number): record
	const teams: { [string]: { [string]: member } } = {}
	for team_index = 1, QUEUE_CONFIG.modes[mode].teams do
		teams[`team{team_index}`] = {}
	end
	return {
		id = id,
		mode = mode,
		matchmaking_type = matchmaking_type,
		status = "waiting",
		teams = teams,
		arrival_deadline = 0,
		destination_job_id = "",
	}
end

local function count_members(entry: record): number
	local count = 0
	for _, members in entry.teams do
		for _ in members do
			count += 1
		end
	end
	return count
end

local function find_member(entry: record, user_id: number): member?
	const key = tostring(user_id)
	for _, members in entry.teams do
		if members[key] then
			return members[key]
		end
	end
	return nil
end

local function prune(entry: record, now: number): ()
	if entry.status == "started" or entry.status == "cancelled" then
		return
	end
	if entry.status == "ready" and now >= entry.arrival_deadline then
		entry.status = "cancelled"
	end
	for _, members in entry.teams do
		for key, member in members do
			if now >= member.expires_at then
				if entry.status == "ready" then
					entry.status = "cancelled"
				end
				members[key] = nil
			end
		end
	end
end

local function claim(entry: record, user_id: number, token: string, source_job_id: string, now: number): boolean
	prune(entry, now)
	if entry.status ~= "waiting" or find_member(entry, user_id) ~= nil then
		return false
	end
	local smallest: { [string]: member }? = nil
	local smallest_size = QUEUE_CONFIG.modes[entry.mode].entities_per_team
	for _, members in entry.teams do
		local size = 0
		for _ in members do
			size += 1
		end
		if size < smallest_size then
			smallest = members
			smallest_size = size
		end
	end
	if smallest == nil then
		return false
	end
	smallest[tostring(user_id)] = {
		user_id = user_id,
		token = token,
		source_job_id = source_job_id,
		expires_at = now + QUEUE_CONFIG.slot_lifetime,
	}
	const settings = QUEUE_CONFIG.modes[entry.mode]
	if count_members(entry) == settings.teams * settings.entities_per_team then
		entry.status = "ready"
		entry.arrival_deadline = now + QUEUE_CONFIG.arrival_timeout
	end
	return true
end

local function renew(entry: record, tokens: { [string]: string }, now: number): ()
	prune(entry, now)
	if entry.status ~= "waiting" and entry.status ~= "ready" then
		return
	end
	for _, members in entry.teams do
		for key, member in members do
			if tokens[key] == member.token then
				member.expires_at = now + QUEUE_CONFIG.slot_lifetime
			end
		end
	end
end

local function release(entry: record, user_id: number, token: string): ()
	if entry.status == "started" then
		return
	end
	const key = tostring(user_id)
	for _, members in entry.teams do
		const member = members[key]
		if member and member.token == token then
			members[key] = nil
			if entry.status == "ready" then
				entry.status = "cancelled"
			end
			return
		end
	end
end

return {
	as_dictionary = as_dictionary,
	claim = claim,
	count_members = count_members,
	create = create,
	decode = decode,
	find_member = find_member,
	parse_mode = parse_mode,
	prune = prune,
	release = release,
	renew = renew,
}
