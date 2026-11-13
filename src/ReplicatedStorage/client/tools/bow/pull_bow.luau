const Players = game:GetService("Players")
const ReplicatedStorage = game:GetService("ReplicatedStorage")

const get_aim_target = require(ReplicatedStorage.client.aim.get_aim_target)
const TOOL_USE_WALKSPEED_MODIFIER = require(ReplicatedStorage.client.tools.TOOL_USE_WALKSPEED_MODIFIER)
const bow_state = require(script.Parent.bow_state)

const shoot_bow = ReplicatedStorage.remotes.shoot_bow

const player = Players.LocalPlayer

local function pull_bow(): ()
	const character = player.Character
	if character == nil then
		return
	end
	const humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid == nil or humanoid.Health <= 0 then
		return
	end
	humanoid.WalkSpeed *= TOOL_USE_WALKSPEED_MODIFIER
	bow_state.draw_started = os.clock()
end

-- i added "f" to stop lua from thinking i'm reffering to the remote (short for function)
local function shoot_bow_f(character: Model, dt: number): ()
	const head = character:FindFirstChild("Head")
	if head == nil or not head:IsA("BasePart") then
		return
	end
	const humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid == nil or humanoid.Health <= 0 then
		return
	end

	const origin = head.Position
	local direction = (get_aim_target().position - origin).Unit
	shoot_bow:InvokeServer(origin, direction, dt)
end

local function release_bow(was_released: boolean): ()
	const draw_started = bow_state.draw_started
	const character = player.Character or player.CharacterAdded:Wait()
	const humanoid = character.Humanoid

	humanoid.WalkSpeed /= TOOL_USE_WALKSPEED_MODIFIER
	bow_state.draw_started = nil
	if was_released and draw_started ~= nil and character ~= nil then
		shoot_bow_f(character, os.clock() - draw_started)
	end
end

return {
	start = pull_bow,
	stop = release_bow,
}
