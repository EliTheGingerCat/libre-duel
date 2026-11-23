const MessagingService = game:GetService("MessagingService")
const ServerScriptService = game:GetService("ServerScriptService")

const GUILD_DATA_CHANGE_TOPIC = require(script.Parent.GUILD_DATA_CHANGE_TOPIC)
const guild_data_change_types = require(script.Parent.guild_data_change_types)
const guild_store = require(ServerScriptService.guild.data.guild_store)
const player_store = require(ServerScriptService.player_data.player_store)

const function get_changed_store_name(store: any): guild_data_change_types.changed_store_name?
	if store == guild_store then
		return "guild"
	elseif store == player_store then
		return "player"
	end
	return nil
end

const function publish(message: guild_data_change_types.guild_data_change_message): ()
	const ok, result = pcall(MessagingService.PublishAsync, MessagingService, GUILD_DATA_CHANGE_TOPIC, message)
	if not ok then
		warn(`Could not broadcast guild data change on "{message.key}": {result}`)
	end
end

-- other servers only reread their sessions every 12 seconds, this tells them to do it now
-- never yields, stores other than guilds and players are ignored
const function broadcast_guild_data_change(store: any, key: string): ()
	const store_name = get_changed_store_name(store)
	if store_name == nil then
		return
	end
	task.spawn(publish, { job_id = game.JobId, store_name = store_name, key = key })
end

return broadcast_guild_data_change
