const is_rate_limited = require(script.Parent.remote_rate_limit)

-- for remotes that return data instead of changing anything, nil when rate limited or it errored
-- the handler must never error, zap would leave the client waiting for an answer forever
const function create_query_remote_handler<argument, result>(
	remote_name: string,
	cooldown: number,
	run_query: (player: Player, argument: argument) -> result?
): (player: Player, argument: argument) -> result?
	const function on_invoke(player: Player, argument: argument): result?
		if is_rate_limited(player, remote_name, cooldown) then
			return nil
		end
		const ok, result = pcall(run_query, player, argument)
		if not ok then
			warn(`Remote {remote_name} errored: {result}`)
			return nil
		end
		return result
	end
	return on_invoke
end

return create_query_remote_handler
