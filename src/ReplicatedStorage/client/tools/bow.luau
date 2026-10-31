const Players = game:GetService("Players")
const ReplicatedStorage = game:GetService("ReplicatedStorage")

const tool_types = require(script.Parent.tool_types)

const player = Players.LocalPlayer
const mouse = player:GetMouse()
const shoot_bow = ReplicatedStorage.remotes.shoot_bow

local function shoot(character: Model, duration: number): ()
	if character ~= player.Character then
		return
	end
	const head = character:FindFirstChild("Head")
	const humanoid = character:FindFirstChildOfClass("Humanoid")
	if head == nil or not head:IsA("BasePart") or humanoid == nil or humanoid.Health <= 0 then
		return
	end
	const direction = mouse.Hit.Position - head.Position
	if direction.Magnitude <= 0 then
		return
	end
	shoot_bow:InvokeServer(head.Position, direction.Unit, duration)
end

local function create(): tool_types.tool
	local draw_started: number? = nil
	local draw_character: Model? = nil

	local function cancel_use(): ()
		draw_started = nil
		draw_character = nil
	end

	local function begin_use(): ()
		const character = player.Character
		if character == nil or draw_started ~= nil then
			return
		end
		draw_started = os.clock()
		draw_character = character
	end

	local function end_use(): ()
		const started = draw_started
		const character = draw_character
		cancel_use()
		if started ~= nil and character ~= nil then
			task.spawn(shoot, character, os.clock() - started)
		end
	end

	return {
		begin_use = begin_use,
		cancel_use = cancel_use,
		end_use = end_use,
		buffer_click = true,
	}
end

return create
