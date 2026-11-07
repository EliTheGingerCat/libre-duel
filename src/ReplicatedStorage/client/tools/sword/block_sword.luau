const Players = game:GetService("Players")
const ReplicatedStorage = game:GetService("ReplicatedStorage")

const TOOL_USE_WALKSPEED_MODIFIER = require(ReplicatedStorage.client.tools.TOOL_USE_WALKSPEED_MODIFIER)
const sword_state = require(script.Parent.sword_state)

-- suffixing _remote to not confuse roblo
const update_blocking_remote = ReplicatedStorage.remotes.update_blocking

local function set_blocking(blocking: boolean): ()
	const character = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()
	const humanoid = character:WaitForChild("Humanoid")
	if blocking == true then
		humanoid.WalkSpeed *= TOOL_USE_WALKSPEED_MODIFIER
	else
		humanoid.WalkSpeed /= TOOL_USE_WALKSPEED_MODIFIER
	end

	sword_state.blocking = blocking
	update_blocking_remote:InvokeServer(blocking)
end

local function start_blocking(): ()
	set_blocking(true)
end

local function stop_blocking(): ()
	set_blocking(false)
end

return {
	start = start_blocking,
	stop = stop_blocking,
}
