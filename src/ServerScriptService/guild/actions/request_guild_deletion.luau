const ReplicatedStorage = game:GetService("ReplicatedStorage")
const ServerScriptService = game:GetService("ServerScriptService")

const GUILD_DEFAULT_ASSETS = require(ReplicatedStorage.shared.guild.GUILD_DEFAULT_ASSETS)
const delete_guild = require(script.Parent.delete_guild)
const get_player_guild = require(ServerScriptService.guild.membership.get_player_guild)
const send_notification = require(ServerScriptService.notification.send_notification)
const send_popup = require(ServerScriptService.popup.send_popup)

const DELETE_BUTTON_INDEX = 1
const DELETE_HOLD_SECONDS = 2

const function on_popup_answered(player: Player, button_index: number): ()
	if button_index ~= DELETE_BUTTON_INDEX then
		return
	end
	const failure = delete_guild(player)
	send_notification(player, failure or "Your guild was deleted.")
end

-- the guild is only deleted once the owner holds the button in the popup
const function request_guild_deletion(player: Player): string?
	const player_guild = get_player_guild(player)
	if player_guild == nil or not player_guild.is_owner then
		return "Only the guild owner can do that."
	end
	send_popup(player, {
		icon = if player_guild.data.icon ~= "" then player_guild.data.icon else GUILD_DEFAULT_ASSETS.icon,
		text = "This will irreversibly delete your guild. There will be no way to recover it. Are you sure?\n\n<font color='rgb(255, 47, 47)'>There will be no more confirmations after this popup.</font>",
		buttons = {
			{ text = "Delete guild", colour = Color3.fromRGB(255, 47, 47), button_progress_time = DELETE_HOLD_SECONDS },
		},
	}, on_popup_answered)
	return nil
end

return request_guild_deletion
