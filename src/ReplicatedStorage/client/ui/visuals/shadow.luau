local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local React = require(ReplicatedStorage.Packages.react)

local function shadow(props: { [string]: unknown })
	if not RunService:IsStudio() then
		return nil
	end
	return React.createElement("UIShadow", props)
end

return shadow
