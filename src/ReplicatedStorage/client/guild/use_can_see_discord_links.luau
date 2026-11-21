const ReplicatedStorage = game:GetService("ReplicatedStorage")

const React = require(ReplicatedStorage.Packages.react)
const can_see_discord_links = require(script.Parent.can_see_discord_links)

-- false until the policy has been read
const function use_can_see_discord_links(): boolean
	const allowed, set_allowed = React.useState(false)
	const function check_policy(): ()
		const function read_policy(): ()
			set_allowed(can_see_discord_links())
		end
		task.spawn(read_policy)
	end
	React.useEffect(check_policy, {})
	return allowed
end

return use_can_see_discord_links
