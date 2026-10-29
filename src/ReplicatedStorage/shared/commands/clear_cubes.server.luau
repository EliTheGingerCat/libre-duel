local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

local conch = require(ReplicatedStorage.Packages.conch)

conch.register("clear_cubes", {
	description = "Clears all the cubes under the workspace",
	permissions = { "administrator" },
	arguments = function() end,

	callback = function()
		local cleared = 0
		for _, v in pairs(workspace:GetDescendants()) do
			if v.Name:match("Cube #%d+") then
				Debris:AddItem(v, 0)
				cleared += 1
			end
		end
		return `Cleared {cleared} blocks`
	end,
})

print("registered!1")
