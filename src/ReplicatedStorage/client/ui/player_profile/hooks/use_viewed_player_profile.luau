const Players = game:GetService("Players")
const ReplicatedStorage = game:GetService("ReplicatedStorage")

const React = require(ReplicatedStorage.Packages.react)
const fetch_player_profile = require(ReplicatedStorage.client.player_profile.fetch_player_profile)
const player_profile_snapshot_types = require(ReplicatedStorage.shared.player_profile.player_profile_snapshot_types)

type snapshot = player_profile_snapshot_types.player_profile_snapshot

export type viewed_player_profile = {
	-- nil while loading, and never a different player than the one asked for
	snapshot: snapshot?,
	failed: boolean,
}

const player_profile_changed_remote = ReplicatedStorage.remotes.player_profile.player_profile_changed

const function increment(value: number): number
	return value + 1
end

-- fetches the profile every time the menu opens or switches player, and again when the viewer edits their own
const function use_viewed_player_profile(menu_enabled: boolean, user_id: number): viewed_player_profile
	const snapshot: snapshot?, set_snapshot: (snapshot?) -> () = React.useState(nil :: snapshot?)
	const failed, set_failed = React.useState(false)
	const refresh_count, set_refresh_count = React.useState(0)

	const function refetch_when_own_profile_changes(): () -> ()
		const function on_changed(): ()
			if user_id == Players.LocalPlayer.UserId then
				set_refresh_count(increment)
			end
		end
		const connection = player_profile_changed_remote.OnClientEvent:Connect(on_changed)
		const function disconnect(): ()
			connection:Disconnect()
		end
		return disconnect
	end
	React.useEffect(refetch_when_own_profile_changes, { user_id })

	const function fetch_when_shown(): (() -> ())?
		if not menu_enabled then
			return nil
		end
		set_failed(false)
		local cancelled = false
		const function fetch(): ()
			const fetched_snapshot = fetch_player_profile(user_id)
			if cancelled then
				return
			end
			if fetched_snapshot then
				set_snapshot(fetched_snapshot)
			else
				set_failed(true)
			end
		end
		task.spawn(fetch)
		const function cancel(): ()
			cancelled = true
		end
		return cancel
	end
	React.useEffect(fetch_when_shown, { menu_enabled, user_id, refresh_count } :: { unknown })

	return {
		snapshot = if snapshot and snapshot.user_id == user_id then snapshot else nil,
		failed = failed,
	}
end

return use_viewed_player_profile
