const ReplicatedStorage = game:GetService("ReplicatedStorage")
const Players = game:GetService("Players")

const TOOL_USE_WALKSPEED_MODIFIER = require(ReplicatedStorage.client.tools.TOOL_USE_WALKSPEED_MODIFIER)
const cake_state = require(script.Parent.cake_state)

const set_cake_state = ReplicatedStorage.remotes.set_cake_state

local function start_eating(): ()
	const character = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()
	const humanoid = character:WaitForChild("Humanoid")
	cake_state.eating = true
	humanoid.WalkSpeed = humanoid.WalkSpeed * TOOL_USE_WALKSPEED_MODIFIER
	local finished = set_cake_state:InvokeServer(true)
	if finished then
		cake_state.eating = false
		humanoid.WalkSpeed = humanoid.WalkSpeed / TOOL_USE_WALKSPEED_MODIFIER
		-- do something...
	else
		-- do something...
	end
end

local function stop_eating(): ()
	if cake_state.eating then
		const character = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()
		const humanoid = character:WaitForChild("Humanoid")
		cake_state.eating = false
		humanoid.WalkSpeed = humanoid.WalkSpeed / TOOL_USE_WALKSPEED_MODIFIER
		set_cake_state:InvokeServer(false)
	end
end

return {
	start = start_eating,
	stop = stop_eating,
}
