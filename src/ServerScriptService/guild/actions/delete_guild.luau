const ServerScriptService = game:GetService("ServerScriptService")

const get_player_guild = require(ServerScriptService.guild.membership.get_player_guild)
const guild_leaderboard_store = require(ServerScriptService.guild.ranking.guild_leaderboard_store)
const guild_schema = require(ServerScriptService.guild.data.schema.guild_schema)
const guild_store = require(ServerScriptService.guild.data.guild_store)
const guild_tag_store = require(ServerScriptService.guild.data.guild_tag_store)
const player_schema = require(ServerScriptService.player_data.schema.player_schema)
const player_store = require(ServerScriptService.player_data.player_store)
const run_guild_transaction = require(ServerScriptService.guild.data.run_guild_transaction)

type tag_index = { guild_id: string }

-- only call this after the owner confirmed, other members find out through sync_player_guild
const function delete_guild(player: Player): string?
	const player_guild = get_player_guild(player)
	if player_guild == nil or not player_guild.is_owner then
		return "Only the guild owner can do that."
	end
	const guild_id = player_guild.id
	const owner_id = player.UserId
	const function mark_deleted(data: guild_schema.guild_data): guild_schema.guild_data
		if data.owner_id ~= owner_id then
			error("no longer the owner")
		end
		const new_data = table.clone(data)
		new_data.deleted = true
		new_data.members = {}
		new_data.outgoing_invites = {}
		return new_data
	end
	const function release_tag(data: tag_index): tag_index
		return if data.guild_id == guild_id then { guild_id = "" } else data
	end
	const function clear_owner_hint(data: player_schema.player_data): player_schema.player_data
		if data.guild_id ~= guild_id then
			return data
		end
		const new_data = table.clone(data)
		new_data.guild_id = ""
		return new_data
	end
	const deleted = run_guild_transaction({
		{ store = guild_store, key = guild_id, transform = mark_deleted, refresh_after = true },
		{ store = guild_tag_store, key = string.lower(player_guild.data.tag), transform = release_tag },
		{ store = player_store, key = tostring(owner_id), transform = clear_owner_hint, refresh_after = true },
	})
	if not deleted then
		return "Couldn't delete the guild, try again."
	end
	pcall(guild_leaderboard_store.RemoveAsync, guild_leaderboard_store, guild_id)
	return nil
end

return delete_guild
