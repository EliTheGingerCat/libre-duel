const Players = game:GetService("Players")
const ServerScriptService = game:GetService("ServerScriptService")

const create_clear_guild_hint_transform = require(script.Parent.create_clear_guild_hint_transform)
const guild_schema = require(ServerScriptService.guild.data.schema.guild_schema)
const guild_store = require(ServerScriptService.guild.data.guild_store)
const player_store = require(ServerScriptService.player_data.player_store)
const run_guild_transaction = require(ServerScriptService.guild.data.run_guild_transaction)

-- shared by leaving, kicking and banning
-- the hint is cleared in the same transaction because a cached guild missing the player can't prove they were removed
-- totals keep what the member earned, only their own entry goes
const function remove_guild_member_async(guild_id: string, user_id: number, ban: boolean): boolean
	const key = tostring(user_id)
	const function remove_member(data: guild_schema.guild_data): guild_schema.guild_data
		if data.owner_id == user_id then
			error("the owner can't be removed")
		end
		const new_data = table.clone(data)
		const new_members = table.clone(data.members)
		new_members[key] = nil
		new_data.members = new_members
		if ban then
			const new_banned = table.clone(data.banned)
			new_banned[key] = os.time()
			new_data.banned = new_banned
			const new_invites = table.clone(data.outgoing_invites)
			new_invites[key] = nil
			new_data.outgoing_invites = new_invites
		end
		return new_data
	end
	return run_guild_transaction({
		{ store = guild_store, key = guild_id, transform = remove_member, refresh_after = true },
		{
			store = player_store,
			key = key,
			transform = create_clear_guild_hint_transform(guild_id),
			refresh_after = Players:GetPlayerByUserId(user_id) ~= nil,
		},
	})
end

return remove_guild_member_async
