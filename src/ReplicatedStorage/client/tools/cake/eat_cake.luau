const ReplicatedStorage = game:GetService("ReplicatedStorage")
const Players = game:GetService("Players")

const TOOL_USE_WALKSPEED_MODIFIER = require(ReplicatedStorage.client.tools.TOOL_USE_WALKSPEED_MODIFIER)
const cake_state = require(script.Parent.cake_state)

const set_cake_state = ReplicatedStorage.remotes.set_cake_state

local cached_walkspeed: number? = nil

const function restore_walkspeed(humanoid: Humanoid): ()
	if cached_walkspeed ~= nil then
		humanoid.WalkSpeed = cached_walkspeed
		cached_walkspeed = nil
	end
end

const function start_eating(): ()
	const character = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()
	const humanoid = character:WaitForChild("Humanoid") :: Humanoid
	cake_state.eating = true
	cached_walkspeed = humanoid.WalkSpeed
	humanoid.WalkSpeed = humanoid.WalkSpeed * TOOL_USE_WALKSPEED_MODIFIER
	local finished = set_cake_state:InvokeServer(true)
	if finished then
		cake_state.eating = false
		restore_walkspeed(humanoid)
		-- do something...
	else
		cake_state.eating = false
		restore_walkspeed(humanoid)
		-- do something...
	end
end

const function stop_eating(): ()
	if cake_state.eating then
		const character = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()
		const humanoid = character:WaitForChild("Humanoid") :: Humanoid
		cake_state.eating = false
		restore_walkspeed(humanoid)
		set_cake_state:InvokeServer(false)
	end
end

return {
	start = start_eating,
	stop = stop_eating,
}
