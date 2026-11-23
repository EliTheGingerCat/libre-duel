const Players = game:GetService("Players")
const ReplicatedStorage = game:GetService("ReplicatedStorage")
const ServerScriptService = game:GetService("ServerScriptService")

const COLOURS = require(ReplicatedStorage.shared.ui.COLOURS)
const recent_reports = require(script.Parent.recent_reports)
const send_notification = require(ServerScriptService.notification.send_notification)
const send_popup = require(ServerScriptService.popup.send_popup)

const POPUP_ICON = "rbxassetid://115802146437284"
const REPORT_BUTTON_INDEX = 1
const REASON_INPUT = "reason"
const REPORT_COOLDOWN = 60

const function get_username(user_id: number): string
	const ok, username = pcall(Players.GetNameFromUserIdAsync, Players, user_id)
	return if ok then username else tostring(user_id)
end

-- yields for the username, the reason is asked for in a popup
-- TODO: reports are only logged to the server output until there is somewhere to send them
const function report_player(player: Player, reported_user_id: number): string?
	if reported_user_id == player.UserId then
		return "You can't report yourself."
	end
	const reports = recent_reports[player] or {}
	recent_reports[player] = reports
	const last_report = reports[reported_user_id]
	if last_report and os.clock() - last_report < REPORT_COOLDOWN then
		return "You already reported this player, give it a minute."
	end
	const reported_username = get_username(reported_user_id)
	const function on_popup_answered(answering_player: Player, button_index: number, values: { [string]: string }): ()
		if button_index ~= REPORT_BUTTON_INDEX then
			return
		end
		const reason = string.match(values[REASON_INPUT] or "", "^%s*(.-)%s*$") or ""
		if reason == "" then
			send_notification(answering_player, "Write a reason so we know what happened.")
			return
		end
		reports[reported_user_id] = os.clock()
		warn(
			`[report] @{answering_player.Name} ({answering_player.UserId}) reported @{reported_username} ({reported_user_id}): {reason}`
		)
		send_notification(answering_player, "Thanks, your report was sent.")
	end
	send_popup(player, {
		icon = POPUP_ICON,
		text = `Why are you reporting @{reported_username}?`,
		text_inputs = { { id = REASON_INPUT, placeholder_text = "What did they do?" } },
		buttons = { { text = "Report", colour = COLOURS.danger } },
	}, on_popup_answered)
	return nil
end

return report_player
