const ReplicatedStorage = game:GetService("ReplicatedStorage")
const ServerScriptService = game:GetService("ServerScriptService")

const filter_text = require(ServerScriptService.text.filter_text)
const guild_snapshot_types = require(ReplicatedStorage.shared.guild.guild_snapshot_types)

-- returns the filtered info, or nil and a message for the player
-- tags have to survive filtering untouched since they're unique and shown everywhere
const function filter_guild_info(
	author: Player,
	info: guild_snapshot_types.guild_info_input
): (guild_snapshot_types.guild_info_input?, string?)
	const name = filter_text(author, info.name)
	const tag = filter_text(author, info.tag)
	const description = filter_text(author, info.description)
	const discord_invite = filter_text(author, info.discord_invite)
	if name == nil or tag == nil or description == nil or discord_invite == nil then
		return nil, "Couldn't check your text right now, try again in a bit."
	end
	if tag ~= info.tag then
		return nil, "That tag isn't allowed."
	end
	return {
		name = name,
		tag = tag,
		description = description,
		icon = info.icon,
		banner = info.banner,
		discord_invite = discord_invite,
	},
		nil
end

return filter_guild_info
