const ServerScriptService = game:GetService("ServerScriptService")

const drop = require(ServerScriptService.ServerPackages.drop)

-- writes straight to the datastore, which also refreshes this server's cache when it holds a session on the key
-- the transform runs on fresh data, so it should error to abort when the data no longer allows the change
const function try_update_async<T>(store: any, key: string, transform: (T) -> T): boolean
	const ok, result = pcall(drop.updateasync, store, key, transform)
	if not ok then
		warn(`Guild update on "{key}" failed: {result}`)
	end
	return ok
end

return try_update_async
