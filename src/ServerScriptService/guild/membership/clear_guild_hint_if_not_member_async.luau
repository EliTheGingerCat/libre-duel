const ServerScriptService = game:GetService("ServerScriptService")

const create_clear_guild_hint_transform = require(script.Parent.create_clear_guild_hint_transform)
const drop = require(ServerScriptService.ServerPackages.drop)
const guild_schema = require(ServerScriptService.guild.data.schema.guild_schema)
const guild_store = require(ServerScriptService.guild.data.guild_store)
const player_store = require(ServerScriptService.player_data.player_store)
const run_guild_transaction = require(ServerScriptService.guild.data.run_guild_transaction)

-- recovery for a hint pointing at a guild that doesn't list the player, removals clear the hint themselves
-- a cached or plain read can be behind or land mid commit, so only a transaction gets to decide
-- drop won't prepare a key that has another transaction pending, so a join still landing aborts this instead
const function clear_guild_hint_if_not_member_async(user_id: number, guild_id: string): boolean
	const key = tostring(user_id)
	-- a fresh read settles most mismatches, which are just a cache that hasn't caught up yet
	const ok, fresh_data = pcall(drop.viewasync, guild_store, guild_id)
	if ok and fresh_data.members[key] ~= nil then
		return false
	end
	const function confirm_not_member(data: guild_schema.guild_data): guild_schema.guild_data
		if data.members[key] ~= nil then
			error("still a member")
		end
		return data
	end
	return run_guild_transaction({
		{ store = guild_store, key = guild_id, transform = confirm_not_member },
		{
			store = player_store,
			key = key,
			transform = create_clear_guild_hint_transform(guild_id),
			refresh_after = true,
		},
	})
end

return clear_guild_hint_if_not_member_async
