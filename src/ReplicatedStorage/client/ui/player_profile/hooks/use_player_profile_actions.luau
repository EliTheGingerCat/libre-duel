const ReplicatedStorage = game:GetService("ReplicatedStorage")

const player_profile_types = require(script.Parent.Parent.player_profile_types)
const request_player_profile_action = require(ReplicatedStorage.client.player_profile.request_player_profile_action)

const function run_action(name: request_player_profile_action.action_name, argument: unknown?): ()
	task.spawn(request_player_profile_action, name, argument)
end

const function change_banner(): ()
	run_action("request_player_banner_change")
end

const function edit_bio(bio: string): ()
	run_action("edit_player_bio", bio)
end

-- every button in the profile menu ends up here and gets sent to the server
const function use_player_profile_actions(viewed_user_id: number): player_profile_types.actions
	const function report(): ()
		-- the server answers with a popup asking for the reason, nothing is reported yet
		run_action("report_player", viewed_user_id)
	end
	return {
		on_change_banner = change_banner,
		on_edit_bio = edit_bio,
		on_report = report,
	}
end

return use_player_profile_actions
