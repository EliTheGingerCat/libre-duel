const ReplicatedStorage = game:GetService("ReplicatedStorage")
const ServerScriptService = game:GetService("ServerScriptService")

const filter_text = require(ServerScriptService.text.filter_text)
const get_player_guild = require(ServerScriptService.guild.membership.get_player_guild)
const guild_schema = require(ServerScriptService.guild.data.schema.guild_schema)
const guild_snapshot_types = require(ReplicatedStorage.shared.guild.guild_snapshot_types)
const guild_store = require(ServerScriptService.guild.data.guild_store)
const guild_tag_store = require(ServerScriptService.guild.data.guild_tag_store)
const run_guild_transaction = require(ServerScriptService.guild.data.run_guild_transaction)
const try_update_async = require(ServerScriptService.guild.data.try_update_async)
const validate_guild_info = require(ReplicatedStorage.shared.guild.validate_guild_info)
const validate_image_asset = require(ServerScriptService.assets.validate_image_asset)

type tag_index = { guild_id: string }
type text_field = "name" | "tag" | "description" | "discord_invite"

const TEXT_FIELDS: { text_field } = { "name", "tag", "description", "discord_invite" }

-- merges the changes onto the saved info, so two quick edits of different fields never undo each other
const function edit_guild_info(player: Player, changes: guild_snapshot_types.guild_info_changes): string?
	const player_guild = get_player_guild(player)
	if player_guild == nil or not player_guild.is_owner then
		return "Only the guild owner can do that."
	end
	const current = player_guild.data
	const info: guild_snapshot_types.guild_info_input = {
		name = changes.name or current.name,
		tag = changes.tag or current.tag,
		description = changes.description or current.description,
		icon = changes.icon or current.icon,
		banner = changes.banner or current.banner,
		discord_invite = changes.discord_invite or current.discord_invite,
	}
	const invalid_reason = validate_guild_info(info)
	if invalid_reason then
		return invalid_reason
	end
	if
		(info.icon ~= current.icon and not validate_image_asset(info.icon))
		or (info.banner ~= current.banner and not validate_image_asset(info.banner))
	then
		return "That isn't an image id. Decal ids don't work, use the image id behind the decal."
	end
	-- only changed text gets filtered, the saved text already was
	for _, field in TEXT_FIELDS do
		if info[field] ~= current[field] then
			const filtered = filter_text(player, info[field])
			if filtered == nil then
				return "Couldn't check your text right now, try again in a bit."
			end
			if field == "tag" and filtered ~= info.tag then
				return "That tag isn't allowed."
			end
			info[field] = filtered
		end
	end

	const guild_id = player_guild.id
	const owner_id = player.UserId
	const function apply_info(data: guild_schema.guild_data): guild_schema.guild_data
		if data.deleted or data.owner_id ~= owner_id then
			error("no longer the owner")
		end
		const new_data = table.clone(data)
		new_data.name = info.name
		new_data.tag = info.tag
		new_data.description = info.description
		new_data.icon = info.icon
		new_data.banner = info.banner
		new_data.discord_invite = info.discord_invite
		return new_data
	end

	const old_tag_key = string.lower(current.tag)
	const new_tag_key = string.lower(info.tag)
	if old_tag_key == new_tag_key then
		return if try_update_async(guild_store, guild_id, apply_info) then nil else "Couldn't save, try again."
	end
	const function release_old_tag(data: tag_index): tag_index
		return if data.guild_id == guild_id then { guild_id = "" } else data
	end
	const function claim_new_tag(data: tag_index): tag_index
		if data.guild_id ~= "" then
			error("tag taken")
		end
		return { guild_id = guild_id }
	end
	const saved = run_guild_transaction({
		{ store = guild_store, key = guild_id, transform = apply_info, refresh_after = true },
		{ store = guild_tag_store, key = old_tag_key, transform = release_old_tag },
		{ store = guild_tag_store, key = new_tag_key, transform = claim_new_tag },
	})
	return if saved then nil else "Couldn't save, that tag might be taken."
end

return edit_guild_info
