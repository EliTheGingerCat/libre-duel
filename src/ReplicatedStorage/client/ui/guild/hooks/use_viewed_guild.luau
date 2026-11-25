const ReplicatedStorage = game:GetService("ReplicatedStorage")

const React = require(ReplicatedStorage.Packages.react)
const fetch_guild_info = require(ReplicatedStorage.client.guild.fetch_guild_info)
const guild_snapshot_types = require(ReplicatedStorage.shared.guild.guild_snapshot_types)
const guild_types = require(script.Parent.Parent.guild_types)

export type viewed_guild = {
	snapshot: guild_snapshot_types.guild_snapshot?,
	page: guild_types.viewed_page,
	view: (guild_id: string) -> (),
	select_page: (page: guild_types.viewed_page) -> (),
	close: () -> (),
}

-- another guild shown read only, it outlives the menu closing so going back to it keeps its tab
const function use_viewed_guild(): viewed_guild
	const snapshot: guild_snapshot_types.guild_snapshot?, set_snapshot: (guild_snapshot_types.guild_snapshot?) -> () =
		React.useState(nil :: guild_snapshot_types.guild_snapshot?)
	const page: guild_types.viewed_page, set_page: (guild_types.viewed_page) -> () =
		React.useState("info" :: guild_types.viewed_page)
	const viewed_guild_id_ref = React.useRef(nil :: string?)

	const function close(): ()
		viewed_guild_id_ref.current = nil
		set_snapshot(nil)
	end

	-- viewing the guild that's already showing just refetches it
	const function view(guild_id: string): ()
		if viewed_guild_id_ref.current ~= guild_id then
			viewed_guild_id_ref.current = guild_id
			set_snapshot(nil)
			set_page("info")
		end
		const function fetch(): ()
			const fetched_snapshot = fetch_guild_info(guild_id)
			-- navigation may have moved on while the fetch was in flight
			if fetched_snapshot and viewed_guild_id_ref.current == guild_id then
				set_snapshot(fetched_snapshot)
			end
		end
		task.spawn(fetch)
	end

	return { snapshot = snapshot, page = page, view = view, select_page = set_page, close = close }
end

return use_viewed_guild
