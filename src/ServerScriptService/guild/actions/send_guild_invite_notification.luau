const ReplicatedStorage = game:GetService("ReplicatedStorage")
const ServerScriptService = game:GetService("ServerScriptService")

const COLOURS = require(ReplicatedStorage.shared.ui.COLOURS)
const GUILD_DEFAULT_ASSETS = require(ReplicatedStorage.shared.guild.GUILD_DEFAULT_ASSETS)
const accept_guild_invite = require(script.Parent.accept_guild_invite)
const decline_guild_invite = require(script.Parent.decline_guild_invite)
const guild_schema = require(ServerScriptService.guild.data.schema.guild_schema)
const send_large_notification = require(ServerScriptService.notification.large_notification.send_large_notification)
const send_notification = require(ServerScriptService.notification.send_notification)

const ACCEPT_BUTTON_INDEX = 1
const DECLINE_BUTTON_INDEX = 2

-- only reaches invitees on this server, everyone else sees the invite in their inbox
const function send_guild_invite_notification(
	target: Player,
	inviter: Player,
	guild_id: string,
	data: guild_schema.guild_data
): ()
	const function on_button_pressed(player: Player, button_index: number): ()
		local failure: string? = nil
		if button_index == ACCEPT_BUTTON_INDEX then
			failure = accept_guild_invite(player, guild_id)
			if failure == nil then
				send_notification(player, `You joined [{data.tag}] {data.name}!`)
			end
		elseif button_index == DECLINE_BUTTON_INDEX then
			failure = decline_guild_invite(player, guild_id)
		end
		if failure then
			send_notification(player, failure)
		end
	end
	send_large_notification(target, {
		icon = if data.icon ~= "" then data.icon else GUILD_DEFAULT_ASSETS.icon,
		text = `@{inviter.Name} invited you to [{data.tag}] {data.name}`,
		buttons = {
			{ text = "Accept", text_colour = COLOURS.green_300 },
			{ text = "Decline", text_colour = COLOURS.danger_text },
		},
	}, on_button_pressed)
end

return send_guild_invite_notification
