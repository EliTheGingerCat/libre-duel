const ReplicatedStorage = game:GetService("ReplicatedStorage")
const ServerScriptService = game:GetService("ServerScriptService")

const GUILD_LIMITS = require(ReplicatedStorage.shared.guild.GUILD_LIMITS)
const conch = require(ReplicatedStorage.Packages.conch)
const count_guild_members = require(ServerScriptService.guild.membership.count_guild_members)
const get_player_guild = require(ServerScriptService.guild.membership.get_player_guild)
const guild_schema = require(ServerScriptService.guild.data.schema.guild_schema)
const guild_store = require(ServerScriptService.guild.data.guild_store)
const normalize_mode_stats = require(ServerScriptService.guild.data.normalize_mode_stats)
const try_update_async = require(ServerScriptService.guild.data.try_update_async)

-- negative ids are never real players, and studio test players only use the first few
local next_fake_user_id = -1000000

const function get_arguments()
	return conch.args.player("player", "A player in a guild"),
		conch.args.number("amount", "How many fake members to add")
end

-- for testing the member cap and long member lists, the fake members never get removed on their own
const function guild_add_fake_member(player: Player, amount: number?): string
	const player_guild = get_player_guild(player)
	if player_guild == nil then
		return `{player.Name} is not in a guild on this server`
	end
	const to_add = math.clamp(amount or 1, 1, GUILD_LIMITS.MAX_MEMBERS)
	const fake_ids = {}
	for _ = 1, to_add do
		table.insert(fake_ids, tostring(next_fake_user_id))
		next_fake_user_id -= 1
	end
	const function add_fake_members(data: guild_schema.guild_data): guild_schema.guild_data
		const new_data = table.clone(data)
		const new_members = table.clone(data.members)
		for _, fake_id in fake_ids do
			if count_guild_members({ members = new_members } :: any) >= GUILD_LIMITS.MAX_MEMBERS then
				break
			end
			new_members[fake_id] = { joined = os.time(), banner = "", playtime = 0, stats = normalize_mode_stats(nil) }
		end
		new_data.members = new_members
		return new_data
	end
	if not try_update_async(guild_store, player_guild.id, add_fake_members) then
		return "Could not update the guild"
	end
	return `Added fake members to [{player_guild.data.tag}], it stops at {GUILD_LIMITS.MAX_MEMBERS}`
end

conch.register("guild_add_fake_member", {
	description = "Adds fake members to a player's guild for testing",
	permissions = { "administrator" },
	arguments = get_arguments,
	callback = guild_add_fake_member,
})
