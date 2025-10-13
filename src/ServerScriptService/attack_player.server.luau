local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local play_sound_excluding = require(script.Parent.modules.play_sound_excluding)
local player_range_server = require(script.Parent.modules.player_range_server)

local damage = 10
local knockback_pitch_range = NumberRange.new(30, 100)
local knockback_yaw_magnitude = 30

local function clamp_range(n: number, range: NumberRange): number
	return math.clamp(n, range.Min, range.Max)
end

type delay = {
	frames: number,
	callback: () -> (),
}
local delays: {delay} = {}
local function delay_for_frames(frames: number, callback: () -> ()): ()
	table.insert(delays, {
		frames = frames,
		callback = callback,
	})
end

local function on_heartbeat(): ()
	local indices_garbage = {}
	for index, delay in delays do
		delay.frames -= 1
		if delay.frames <= 0 then
			delay.callback()
			table.insert(indices_garbage, index)
		end
	end
	local offset = 0
	for _, index in indices_garbage do
		table.remove(delays, index - offset)
		offset += 1
	end
end
RunService.Heartbeat:Connect(on_heartbeat)

local function on_event(player: Player, target_character: unknown): ()
	if typeof(target_character) ~= "Instance" then
		return
	end

	if not target_character:IsA("Model") then
		return
	end

	local target_root = target_character:FindFirstChild("HumanoidRootPart") :: Part?
	if target_root == nil then
		return
	end

	local target_position = target_root.CFrame.Position

	local attacker_character = player.Character
	if attacker_character == nil then
		return
	end

	local attacker_root = attacker_character:FindFirstChild("HumanoidRootPart") :: Part?
	if attacker_root == nil then
		return
	end

	local attacker_position = attacker_root.CFrame.Position
	
	local attack_vector = target_position - attacker_position
	
	local distance = attack_vector.Magnitude
	if distance > player_range_server then
		return
	end

	local target_humanoid = target_character:FindFirstChildOfClass("Humanoid")
	if target_humanoid == nil then
		return
	end

	target_humanoid.Health -= damage

	local knockback_pitch_value = clamp_range(attack_vector.Y, knockback_pitch_range)
	local knockback_pitch = Vector3.new(0, knockback_pitch_value, 0)
	target_root.AssemblyLinearVelocity += knockback_pitch

	local attack_yaw = Vector3.new(attack_vector.X, 0, attack_vector.Z)
	local knockback_yaw = attack_yaw.Unit * knockback_yaw_magnitude
	local function apply_yaw(): ()
		target_root.AssemblyLinearVelocity += knockback_yaw
	end
	delay_for_frames(10, apply_yaw)

	play_sound_excluding(player, "player_damaged", attacker_position)
end

ReplicatedStorage.remotes.attack_player.OnServerEvent:Connect(on_event)
