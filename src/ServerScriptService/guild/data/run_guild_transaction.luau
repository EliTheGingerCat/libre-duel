const ServerScriptService = game:GetService("ServerScriptService")

const broadcast_guild_data_change =
	require(ServerScriptService.guild.replication.cross_server.broadcast_guild_data_change)
const drop = require(ServerScriptService.ServerPackages.drop)

export type transaction_step = {
	-- a drop store, typed loosely since drop's Store type doesn't make it through the package link
	store: any,
	key: string,
	-- runs on fresh data, error inside it to abort the whole transaction
	transform: (any) -> any,
	-- reread afterwards so a session on this server sees the result right away instead of on its next refresh
	refresh_after: boolean?,
}

-- applies every step or none of them
const function run_guild_transaction(steps: { transaction_step }): boolean
	const function queue_steps(queue_step: (store: any, key: string, transform: (any) -> any) -> ()): ()
		for _, step in steps do
			queue_step(step.store, step.key, step.transform)
		end
	end
	const function on_error(message: unknown): ()
		warn(`Guild transaction failed: {message}`)
	end
	if not xpcall(drop.txasync :: any, on_error, queue_steps) then
		return false
	end
	for _, step in steps do
		if step.refresh_after then
			pcall(drop.viewasync, step.store, step.key)
		end
		broadcast_guild_data_change(step.store, step.key)
	end
	return true
end

return run_guild_transaction
