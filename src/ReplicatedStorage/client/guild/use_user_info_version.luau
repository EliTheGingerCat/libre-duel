const ReplicatedStorage = game:GetService("ReplicatedStorage")

const React = require(ReplicatedStorage.Packages.react)
const user_info_cache = require(script.Parent.user_info_cache)

-- rerenders whenever new names arrive, read them with user_info_cache.get during render
const function use_user_info_version(): number
	const version, set_version = React.useState(0)
	const function subscribe(): () -> ()
		local current = 0
		const function bump(): ()
			current += 1
			set_version(current)
		end
		return user_info_cache.subscribe(bump)
	end
	React.useEffect(subscribe, {})
	return version
end

return use_user_info_version
