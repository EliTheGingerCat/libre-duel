local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- This is helpful:
-- > local humanoid = game:GetService("Workspace"):FindFirstChild("clone of " .. game:GetService("Players"):GetPlayers()[1].Name).Humanoid humanoid.Health = humanoid.MaxHealth
-- (Make sure to run in server.)

local enabled = false
if RunService:IsStudio() and enabled then
	local function clone_maybe_not_archivable<T>(instance: T & Instance): T
		local archivable = instance.Archivable
		instance.Archivable = true
		local clone = instance:Clone()
		instance.Archivable = archivable
		return clone
	end

	local function on_player_added(player: Player): ()
		local function on_character(character: Model): ()
			local clone = clone_maybe_not_archivable(character)
			clone.Name = `clone of {character.Name}`

			clone:PivotTo(character:GetPivot() * CFrame.new(Vector3.new(3, 0, 0)))
			clone.Parent = workspace
		end

		if player.Character ~= nil and player:HasAppearanceLoaded() then
			on_character(player.Character)
		else
			player.CharacterAppearanceLoaded:Once(on_character)
		end
	end

	Players.PlayerAdded:Connect(on_player_added)
end
