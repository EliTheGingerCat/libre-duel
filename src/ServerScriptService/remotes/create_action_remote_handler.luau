const ServerScriptService = game:GetService("ServerScriptService")

const is_rate_limited = require(script.Parent.remote_rate_limit)
const send_notification = require(ServerScriptService.notification.send_notification)

export type action_result = { ok: boolean, error: string? }

const ACTION_COOLDOWN = 1

-- run_action returns a message when it failed, which is also shown to the player as a notification
-- zap already checked the argument types, run_action still has to validate the values
-- the handler must never error, zap would leave the client waiting for an answer forever
const function create_action_remote_handler<argument...>(
	remote_name: string,
	run_action: (player: Player, argument...) -> string?
): (player: Player, argument...) -> action_result
	const function on_invoke(player: Player, ...: argument...): action_result
		if is_rate_limited(player, remote_name, ACTION_COOLDOWN) then
			return { ok = false, error = "Slow down a bit." }
		end
		const ok, result = pcall(run_action, player, ...)
		if not ok then
			warn(`Remote {remote_name} errored: {result}`)
		end
		const failure = if ok then result else "Something went wrong, try again."
		if failure then
			send_notification(player, failure)
			return { ok = false, error = failure }
		end
		return { ok = true }
	end
	return on_invoke
end

return create_action_remote_handler
