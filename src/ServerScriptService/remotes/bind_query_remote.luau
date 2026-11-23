const is_rate_limited = require(script.Parent.remote_rate_limit)

-- for remotes that return data instead of changing anything, nil when rate limited or it errored
const function bind_query_remote(
	remote: RemoteFunction,
	cooldown: number,
	run_query: (player: Player, ...unknown) -> unknown
): ()
	const function on_invoke(player: Player, ...: unknown): unknown
		if is_rate_limited(player, remote.Name, cooldown) then
			return nil
		end
		const ok, result = pcall(run_query, player, ...)
		if not ok then
			warn(`Remote {remote.Name} errored: {result}`)
			return nil
		end
		return result
	end
	remote.OnServerInvoke = on_invoke
end

return bind_query_remote
