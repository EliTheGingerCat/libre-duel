local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.react)
local settings_registry = require(script.Parent.settings_registry)

const function use_setting(id: string): settings_registry.value?
	local value, set_value = React.useState(settings_registry.get(id))
	const function subscribe()
		const function update(): ()
			set_value(settings_registry.get(id))
		end
		local disconnect = settings_registry.subscribe(update)
		update()
		return disconnect
	end
	React.useEffect(subscribe, { id })
	return value
end

return use_setting
