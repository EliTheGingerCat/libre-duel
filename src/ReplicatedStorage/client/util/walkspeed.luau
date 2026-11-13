const Players = game:GetService("Players")
const StarterPlayer = game:GetService("StarterPlayer")

-- every system that slows the player registers a named multiplier here instead of writing WalkSpeed itself,
-- otherwise they cache/restore each other's values and the player gets stuck slow (or fast)
const player = Players.LocalPlayer

const modifiers: { [string]: number } = {}

const function apply(): ()
	const character = player.Character
	if character == nil then
		return
	end
	const humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid == nil then
		return
	end
	local speed = StarterPlayer.CharacterWalkSpeed
	for _, multiplier in modifiers do
		speed *= multiplier
	end
	humanoid.WalkSpeed = speed
end

const function set_modifier(key: string, multiplier: number?): ()
	if modifiers[key] == multiplier then
		return
	end
	modifiers[key] = multiplier
	apply()
end

const function on_character_added(character: Model): ()
	character:WaitForChild("Humanoid")
	apply()
end

player.CharacterAdded:Connect(on_character_added)

return {
	set_modifier = set_modifier,
}
