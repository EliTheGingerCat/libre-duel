const ReplicatedStorage = game:GetService("ReplicatedStorage")
const ServerScriptService = game:GetService("ServerScriptService")

const COLOURS = require(ReplicatedStorage.shared.ui.COLOURS)
const edit_guild_info = require(script.Parent.edit_guild_info)
const get_player_guild = require(ServerScriptService.guild.membership.get_player_guild)
const parse_image_id = require(ServerScriptService.assets.parse_image_id)
const send_notification = require(ServerScriptService.notification.send_notification)
const send_popup = require(ServerScriptService.popup.send_popup)

export type image_kind = "icon" | "banner"

const POPUP_ICON = "rbxassetid://115802146437284"
const SAVE_BUTTON_INDEX = 1
const IMAGE_ID_INPUT = "image_id"

-- the new image is asked for in a popup, nothing changes until the owner saves it
const function request_guild_image_change(player: Player, kind: image_kind): string?
	const player_guild = get_player_guild(player)
	if player_guild == nil or not player_guild.is_owner then
		return "Only the guild owner can do that."
	end
	const function on_popup_answered(answering_player: Player, button_index: number, values: { [string]: string }): ()
		if button_index ~= SAVE_BUTTON_INDEX then
			return
		end
		const image = parse_image_id(values[IMAGE_ID_INPUT] or "")
		if image == nil then
			send_notification(answering_player, "That doesn't look like an image id.")
			return
		end
		const failure =
			edit_guild_info(answering_player, if kind == "icon" then { icon = image } else { banner = image })
		send_notification(answering_player, failure or `Guild {kind} updated.`)
	end
	send_popup(player, {
		icon = POPUP_ICON,
		text = `Paste the image id of your new guild {kind}.`,
		text_inputs = { { id = IMAGE_ID_INPUT, placeholder_text = "e.g. 115802146437284" } },
		buttons = { { text = "Save", colour = COLOURS.white } },
	}, on_popup_answered)
	return nil
end

return request_guild_image_change
