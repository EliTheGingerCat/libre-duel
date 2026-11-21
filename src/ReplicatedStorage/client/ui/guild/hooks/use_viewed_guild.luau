const ReplicatedStorage = game:GetService("ReplicatedStorage")

const React = require(ReplicatedStorage.Packages.react)
const fetch_guild_info = require(ReplicatedStorage.client.guild.fetch_guild_info)
const guild_snapshot_types = require(ReplicatedStorage.shared.guild.guild_snapshot_types)

export type viewed_guild = {
	snapshot: guild_snapshot_types.guild_snapshot?,
	view: (guild_id: string) -> (),
	close: () -> (),
}

-- another guild opened read only from an invite, forgotten whenever the menu closes
const function use_viewed_guild(menu_enabled: boolean): viewed_guild
	const snapshot: guild_snapshot_types.guild_snapshot?, set_snapshot: (guild_snapshot_types.guild_snapshot?) -> () =
		React.useState(nil :: guild_snapshot_types.guild_snapshot?)

	const menu_enabled_ref = React.useRef(menu_enabled)
	menu_enabled_ref.current = menu_enabled

	const function close(): ()
		set_snapshot(nil)
	end

	const function clear_when_menu_closes(): ()
		if not menu_enabled then
			set_snapshot(nil)
		end
	end
	React.useEffect(clear_when_menu_closes, { menu_enabled })

	const function view(guild_id: string): ()
		const function fetch(): ()
			const fetched_snapshot = fetch_guild_info(guild_id)
			-- the menu may have closed while the fetch was in flight
			if fetched_snapshot and menu_enabled_ref.current then
				set_snapshot(fetched_snapshot)
			end
		end
		task.spawn(fetch)
	end

	return { snapshot = snapshot, view = view, close = close }
end

return use_viewed_guild
