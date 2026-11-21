const ServerScriptService = game:GetService("ServerScriptService")

const is_rate_limited = require(script.Parent.guild_rate_limit)
const send_notification = require(ServerScriptService.notification.send_notification)

export type action_result = { ok: boolean, error: string? }

const ACTION_COOLDOWN = 1

-- run_action returns a message when it failed, which is also shown to the player as a notification
-- it gets the raw arguments and has to validate them itself
const function bind_guild_action_remote(remote: RemoteFunction, run_action: (player: Player, ...unknown) -> string?): ()
	const function on_invoke(player: Player, ...: unknown): action_result
		if is_rate_limited(player, remote.Name, ACTION_COOLDOWN) then
			return { ok = false, error = "Slow down a bit." }
		end
		const ok, result = pcall(run_action, player, ...)
		if not ok then
			warn(`Guild remote {remote.Name} errored: {result}`)
		end
		const failure = if ok then result else "Something went wrong, try again."
		if failure then
			send_notification(player, failure)
			return { ok = false, error = failure }
		end
		return { ok = true }
	end
	remote.OnServerInvoke = on_invoke
end

return bind_guild_action_remote
