-- a zap funct whose handler errors never answers, which leaves the client waiting forever
-- this answers with fallback instead
const function create_protected_remote_handler<result, argument...>(
	remote_name: string,
	fallback: result,
	handler: (player: Player, argument...) -> result
): (player: Player, argument...) -> result
	const function on_invoke(player: Player, ...: argument...): result
		const ok, result = pcall(handler, player, ...)
		if not ok then
			warn(`Remote {remote_name} errored: {result}`)
			return fallback
		end
		return result
	end
	return on_invoke
end

return create_protected_remote_handler
