const ReplicatedStorage = game:GetService("ReplicatedStorage")

const player_profile_changed_remote = ReplicatedStorage.remotes.player_profile.player_profile_changed

-- tells the player their own profile changed so an open profile menu fetches it again
const function notify_player_profile_changed(player: Player): ()
	player_profile_changed_remote:FireClient(player)
end

return notify_player_profile_changed
