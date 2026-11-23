const ReplicatedStorage = game:GetService("ReplicatedStorage")
const ServerScriptService = game:GetService("ServerScriptService")

const COLOURS = require(ReplicatedStorage.shared.ui.COLOURS)
const drop = require(ServerScriptService.ServerPackages.drop)
const get_cached_player_data = require(ServerScriptService.player_data.get_cached_player_data)
const notify_player_profile_changed =
	require(ServerScriptService.player_profile.replication.notify_player_profile_changed)
const parse_image_id = require(ServerScriptService.assets.parse_image_id)
const player_schema = require(ServerScriptService.player_data.schema.player_schema)
const player_store = require(ServerScriptService.player_data.player_store)
const send_notification = require(ServerScriptService.notification.send_notification)
const send_popup = require(ServerScriptService.popup.send_popup)
const set_player_banner_attribute = require(ServerScriptService.player_profile.replication.set_player_banner_attribute)
const sync_player_guild = require(ServerScriptService.guild.session.sync_player_guild)
const validate_image_asset = require(ServerScriptService.assets.validate_image_asset)

const POPUP_ICON = "rbxassetid://115802146437284"
const SAVE_BUTTON_INDEX = 1
const IMAGE_ID_INPUT = "image_id"

const function save_banner(player: Player, banner: string): ()
	const function set_banner(data: player_schema.player_data): player_schema.player_data
		const new_data = table.clone(data)
		new_data.player_banner_id = banner
		return new_data
	end
	drop.update(player_store, tostring(player.UserId), set_banner)
	set_player_banner_attribute(player, banner)
	-- guild member rows show a copy of the banner, the sync updates it
	sync_player_guild.sync_player_guild(player)
	notify_player_profile_changed(player)
end

const function on_popup_answered(player: Player, button_index: number, values: { [string]: string }): ()
	if button_index ~= SAVE_BUTTON_INDEX then
		return
	end
	const banner = parse_image_id(values[IMAGE_ID_INPUT] or "")
	if banner == nil then
		send_notification(player, "That doesn't look like an image id.")
		return
	end
	if not validate_image_asset(banner) then
		send_notification(player, "That isn't an image id. Decal ids don't work, use the image id behind the decal.")
		return
	end
	if get_cached_player_data(player) == nil then
		send_notification(player, "Your data hasn't loaded yet.")
		return
	end
	save_banner(player, banner)
	send_notification(player, "Banner updated.")
end

-- the new banner is asked for in a popup, nothing changes until the player saves it
const function request_player_banner_change(player: Player): string?
	send_popup(player, {
		icon = POPUP_ICON,
		text = "Paste the image id of your new banner.",
		text_inputs = { { id = IMAGE_ID_INPUT, placeholder_text = "e.g. 115802146437284" } },
		buttons = { { text = "Save", colour = COLOURS.white } },
	}, on_popup_answered)
	return nil
end

return request_player_banner_change
