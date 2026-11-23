const ReplicatedStorage = game:GetService("ReplicatedStorage")
const ServerScriptService = game:GetService("ServerScriptService")

const PLAYER_PROFILE_LIMITS = require(ReplicatedStorage.shared.player_profile.PLAYER_PROFILE_LIMITS)
const drop = require(ServerScriptService.ServerPackages.drop)
const filter_rich_text = require(ServerScriptService.text.filter_rich_text)
const get_cached_player_data = require(ServerScriptService.player_data.get_cached_player_data)
const notify_player_profile_changed =
	require(ServerScriptService.player_profile.replication.notify_player_profile_changed)
const player_schema = require(ServerScriptService.player_data.schema.player_schema)
const player_store = require(ServerScriptService.player_data.player_store)

-- yields while the text is filtered, returns a message for the player when it failed
const function edit_player_bio(player: Player, bio: string): string?
	const length = utf8.len(bio)
	if length == nil then
		return "Invalid request."
	end
	if length > PLAYER_PROFILE_LIMITS.MAX_BIO_LENGTH then
		return `Your bio can't be longer than {PLAYER_PROFILE_LIMITS.MAX_BIO_LENGTH} characters.`
	end
	const data = get_cached_player_data(player)
	if data == nil then
		return "Your data hasn't loaded yet."
	end
	if bio == data.bio then
		return nil
	end
	const filtered = filter_rich_text(player, bio)
	if filtered == nil then
		return "Couldn't check your text right now, try again in a bit."
	end
	const function set_bio(old_data: player_schema.player_data): player_schema.player_data
		const new_data = table.clone(old_data)
		new_data.bio = filtered
		return new_data
	end
	drop.update(player_store, tostring(player.UserId), set_bio)
	notify_player_profile_changed(player)
	return nil
end

return edit_player_bio
