const HttpService = game:GetService("HttpService")
const ReplicatedStorage = game:GetService("ReplicatedStorage")
const ServerScriptService = game:GetService("ServerScriptService")

const drop = require(ServerScriptService.ServerPackages.drop)
const filter_guild_info = require(ServerScriptService.guild.text.filter_guild_info)
const get_cached_player_data = require(ServerScriptService.player_data.get_cached_player_data)
const guild_schema = require(ServerScriptService.guild.data.schema.guild_schema)
const guild_snapshot_types = require(ReplicatedStorage.shared.guild.guild_snapshot_types)
const guild_store = require(ServerScriptService.guild.data.guild_store)
const guild_tag_store = require(ServerScriptService.guild.data.guild_tag_store)
const normalize_mode_stats = require(ServerScriptService.guild.data.normalize_mode_stats)
const player_schema = require(ServerScriptService.player_data.schema.player_schema)
const player_store = require(ServerScriptService.player_data.player_store)
const run_guild_transaction = require(ServerScriptService.guild.data.run_guild_transaction)
const validate_guild_info = require(ReplicatedStorage.shared.guild.validate_guild_info)

type tag_index = { guild_id: string }

const function is_tag_taken(tag_key: string): boolean
	const ok, data = pcall(drop.viewasync, guild_tag_store, tag_key)
	return ok and data.guild_id ~= ""
end

-- returns a message for the player when it failed
const function create_guild(player: Player, requested_info: guild_snapshot_types.guild_info_input): string?
	const player_data = get_cached_player_data(player)
	if player_data == nil then
		return "Your data hasn't loaded yet."
	end
	if player_data.guild_id ~= "" then
		return "You're already in a guild."
	end
	-- icons and banners are set from the manage page once the guild exists
	const info_without_assets = table.clone(requested_info)
	info_without_assets.icon = ""
	info_without_assets.banner = ""
	const invalid_reason = validate_guild_info(info_without_assets)
	if invalid_reason then
		return invalid_reason
	end
	const tag_key = string.lower(info_without_assets.tag)
	if is_tag_taken(tag_key) then
		return "That tag is already taken."
	end
	const info, filter_error = filter_guild_info(player, info_without_assets)
	if info == nil then
		return filter_error
	end

	const guild_id = HttpService:GenerateGUID(false)
	const now = os.time()
	const function set_player_guild(data: player_schema.player_data): player_schema.player_data
		if data.guild_id ~= "" then
			error("already in a guild")
		end
		const new_data = table.clone(data)
		new_data.guild_id = guild_id
		return new_data
	end
	const function fill_guild(data: guild_schema.guild_data): guild_schema.guild_data
		if data.id ~= "" then
			error("guild id collision")
		end
		const new_data = table.clone(data)
		new_data.id = guild_id
		new_data.owner_id = player.UserId
		new_data.created = now
		new_data.name = info.name
		new_data.tag = info.tag
		new_data.description = info.description
		new_data.discord_invite = info.discord_invite
		new_data.members = {
			[tostring(player.UserId)] = {
				joined = now,
				banner = player_data.player_banner_id,
				playtime = 0,
				stats = normalize_mode_stats(nil),
			},
		}
		new_data.totals = normalize_mode_stats(nil)
		return new_data
	end
	const function claim_tag(data: tag_index): tag_index
		if data.guild_id ~= "" then
			error("tag taken")
		end
		return { guild_id = guild_id }
	end
	const created = run_guild_transaction({
		{ store = player_store, key = tostring(player.UserId), transform = set_player_guild, refresh_after = true },
		{ store = guild_store, key = guild_id, transform = fill_guild },
		{ store = guild_tag_store, key = tag_key, transform = claim_tag },
	})
	if not created then
		return if is_tag_taken(tag_key) then "That tag is already taken." else "Couldn't create the guild, try again."
	end
	return nil
end

return create_guild
