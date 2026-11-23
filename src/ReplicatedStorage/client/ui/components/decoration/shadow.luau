local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local React = require(ReplicatedStorage.Packages.react)

const function shadow(props: { [string]: unknown })
	if not RunService:IsStudio() then
		return nil
	end
	return React.createElement("UIShadow", props)
end

return shadow
