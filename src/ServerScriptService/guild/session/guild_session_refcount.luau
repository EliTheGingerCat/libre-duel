const ServerScriptService = game:GetService("ServerScriptService")

const drop = require(ServerScriptService.ServerPackages.drop)
const guild_store = require(ServerScriptService.guild.data.guild_store)

const START_ATTEMPTS = 5
const RETRY_DELAY = 1

-- how many online players on this server need each guild's session
const reference_counts: { [string]: number } = {}
-- tracked here because drop's own session state isn't part of its exported types
const session_states: { [string]: "starting" | "active" } = {}
const waiting_threads: { [string]: { thread } } = {}

const function wake_waiting_threads(guild_id: string): ()
	const threads = waiting_threads[guild_id]
	waiting_threads[guild_id] = nil
	if threads then
		for _, thread in threads do
			task.spawn(thread)
		end
	end
end

const function start_session_with_retries(guild_id: string): boolean
	session_states[guild_id] = "starting"
	for _ = 1, START_ATTEMPTS do
		-- errors while a previous session on the key is still flushing, which clears up on its own
		if pcall(drop.startsession, guild_store, guild_id) then
			drop.waitforsession(guild_store, guild_id)
			session_states[guild_id] = "active"
			wake_waiting_threads(guild_id)
			return true
		end
		task.wait(RETRY_DELAY)
	end
	session_states[guild_id] = nil
	wake_waiting_threads(guild_id)
	return false
end

const function stop_session(guild_id: string): ()
	const function on_error(message: unknown)
		warn(`Could not stop guild session {guild_id}: {message}`)
	end
	-- errors if shutdown already stopped it
	xpcall(drop.stopsessionasync, on_error, guild_store, guild_id)
end

-- yields until the session is live, false when it could not be started in which case no reference is held
const function acquire(guild_id: string): boolean
	const count = (reference_counts[guild_id] or 0) + 1
	reference_counts[guild_id] = count
	if count > 1 then
		if session_states[guild_id] == "starting" then
			waiting_threads[guild_id] = waiting_threads[guild_id] or {}
			table.insert(waiting_threads[guild_id], coroutine.running())
			coroutine.yield()
		end
		if session_states[guild_id] == "active" then
			return true
		end
		reference_counts[guild_id] = math.max((reference_counts[guild_id] or 1) - 1, 0)
		return false
	end
	if start_session_with_retries(guild_id) then
		return true
	end
	reference_counts[guild_id] = nil
	return false
end

const function release(guild_id: string): ()
	const count = (reference_counts[guild_id] or 0) - 1
	if count > 0 then
		reference_counts[guild_id] = count
		return
	end
	reference_counts[guild_id] = nil
	if session_states[guild_id] == "active" then
		session_states[guild_id] = nil
		task.spawn(stop_session, guild_id)
	end
end

const function get_active_guild_ids(): { string }
	const guild_ids = {}
	for guild_id in reference_counts do
		if session_states[guild_id] == "active" then
			table.insert(guild_ids, guild_id)
		end
	end
	return guild_ids
end

-- true when drop.view and drop.update work for this guild on this server
const function is_active(guild_id: string): boolean
	return session_states[guild_id] == "active"
end

return {
	acquire = acquire,
	is_active = is_active,
	release = release,
	get_active_guild_ids = get_active_guild_ids,
}
