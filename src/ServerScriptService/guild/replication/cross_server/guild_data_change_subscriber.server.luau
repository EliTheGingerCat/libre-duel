const MessagingService = game:GetService("MessagingService")
const Players = game:GetService("Players")
const ServerScriptService = game:GetService("ServerScriptService")

const GUILD_DATA_CHANGE_TOPIC = require(script.Parent.GUILD_DATA_CHANGE_TOPIC)
const drop = require(ServerScriptService.ServerPackages.drop)
const guild_data_change_types = require(script.Parent.guild_data_change_types)
const guild_session_refcount = require(ServerScriptService.guild.session.guild_session_refcount)
const guild_store = require(ServerScriptService.guild.data.guild_store)
const player_store = require(ServerScriptService.player_data.player_store)

const SUBSCRIBE_ATTEMPTS = 3
const RETRY_BACKOFF_BASE = 2

const function parse_message(data: unknown): guild_data_change_types.guild_data_change_message?
	if typeof(data) ~= "table" then
		return nil
	end
	const message = data :: { [string]: unknown }
	if typeof(message.job_id) ~= "string" or typeof(message.key) ~= "string" then
		return nil
	end
	if message.store_name ~= "guild" and message.store_name ~= "player" then
		return nil
	end
	return data :: guild_data_change_types.guild_data_change_message
end

-- the store observers do the actual pushing once the refresh lands
const function refresh_store_key(store: any, key: string): ()
	const ok, result = pcall(drop.viewasync, store, key)
	if not ok then
		warn(`Could not refresh "{key}" after a guild data change: {result}`)
	end
end

const function on_guild_data_change(received: { Data: unknown }): ()
	const message = parse_message(received.Data)
	-- the server that wrote the change already refreshed its own sessions
	if message == nil or message.job_id == game.JobId then
		return
	end
	if message.store_name == "guild" then
		if guild_session_refcount.is_active(message.key) then
			refresh_store_key(guild_store, message.key)
		end
		return
	end
	const user_id = tonumber(message.key)
	if user_id and Players:GetPlayerByUserId(user_id) then
		refresh_store_key(player_store, message.key)
	end
end

const function subscribe(): ()
	for attempt = 1, SUBSCRIBE_ATTEMPTS do
		const ok, result =
			pcall(MessagingService.SubscribeAsync, MessagingService, GUILD_DATA_CHANGE_TOPIC, on_guild_data_change)
		if ok then
			return
		end
		warn(`Could not subscribe to guild data changes: {result}`)
		task.wait(RETRY_BACKOFF_BASE ^ attempt)
	end
end

task.spawn(subscribe)
