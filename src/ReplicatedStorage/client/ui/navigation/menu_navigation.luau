const ReplicatedStorage = game:GetService("ReplicatedStorage")

const Signal = require(ReplicatedStorage.Packages.signal)

-- a nil guild_id is the viewer's own guild
export type destination = { kind: "player_profile", user_id: number } | { kind: "guild", guild_id: string? }
export type destination_kind = "player_profile" | "guild"
-- what menus hear about, closed means every menu closes
export type navigation_event = destination | { kind: "closed" }

const navigated = Signal.new()
-- where the X goes back to, the last entry is what's showing
const history: { destination } = {}

const function is_same_destination(first: destination, second: destination): boolean
	if first.kind == "player_profile" and second.kind == "player_profile" then
		return first.user_id == second.user_id
	elseif first.kind == "guild" and second.kind == "guild" then
		return first.guild_id == second.guild_id
	end
	return false
end

-- the only Fire, wally's package link drops Signal's types so this is what types the signal
const function fire(event: navigation_event): ()
	navigated:Fire(event)
end

const function get_current(): destination?
	return history[#history]
end

-- every menu root listens and opens or closes itself, so one menu can open another without knowing about it
const function go_to(destination: destination): ()
	const current = get_current()
	if current == nil or not is_same_destination(current, destination) then
		table.insert(history, destination)
	end
	fire(destination)
end

const function open_player_profile(user_id: number): ()
	go_to({ kind = "player_profile", user_id = user_id })
end

const function open_guild(guild_id: string): ()
	go_to({ kind = "guild", guild_id = guild_id })
end

-- for a menu opened from the topbar, which starts a new history
const function reset_to(destination: destination): ()
	table.clear(history)
	go_to(destination)
end

const function close_all(): ()
	table.clear(history)
	fire({ kind = "closed" })
end

-- closes everything once there is nothing left to go back to
const function go_back(): ()
	table.remove(history)
	const previous = get_current()
	if previous == nil then
		close_all()
		return
	end
	fire(previous)
end

const function is_showing(kind: destination_kind): boolean
	const current = get_current()
	return current ~= nil and current.kind == kind
end

const function subscribe(callback: (event: navigation_event) -> ()): () -> ()
	const connection = navigated:Connect(callback)
	const function disconnect(): ()
		connection:Disconnect()
	end
	return disconnect
end

return {
	open_player_profile = open_player_profile,
	open_guild = open_guild,
	reset_to = reset_to,
	close_all = close_all,
	go_back = go_back,
	is_showing = is_showing,
	subscribe = subscribe,
}
