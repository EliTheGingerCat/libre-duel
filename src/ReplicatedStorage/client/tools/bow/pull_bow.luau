const Players = game:GetService("Players")
const ReplicatedStorage = game:GetService("ReplicatedStorage")
const UserInputService = game:GetService("UserInputService")

const bow_state = require(script.Parent.bow_state)
const editor_state = require(ReplicatedStorage.client.ui.hud.editor_state)
const KEYBINDS = require(ReplicatedStorage.client.util.KEYBINDS)
const slot_has_behaviour = require(ReplicatedStorage.client.tools.slot_has_behaviour)
const tool_state = require(ReplicatedStorage.client.tools.tool_state)

const shoot_bow = ReplicatedStorage.remotes.shoot_bow

const player = Players.LocalPlayer
const Mouse = player:GetMouse()

local draw_character: Model? = nil

local function cancel_draw(): ()
	bow_state.draw_started = nil
	draw_character = nil
end

local function pull_bow(): ()
	if editor_state.enabled or not slot_has_behaviour(tool_state.current, "bow") then
		return
	end
	const character = player.Character
	if character == nil then
		return
	end
	const humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid == nil or humanoid.Health <= 0 then
		return
	end
	bow_state.draw_started = os.clock()
	draw_character = character
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
	local direction = (Mouse.Hit.Position - origin).Unit
	shoot_bow:InvokeServer(origin, direction, dt)
end

local function on_input_ended(input: InputObject, game_processed: boolean): ()
	if input.UserInputType ~= KEYBINDS.tool_use then
		return
	end

	const started = bow_state.draw_started
	const character = draw_character
	cancel_draw()
	if game_processed or editor_state.enabled or not slot_has_behaviour(tool_state.current, "bow") then
		return
	end
	if started == nil or character == nil or character ~= player.Character then
		return
	end
	shoot_bow_f(character, os.clock() - started)
end

local function on_tool_changed(slot: number): ()
	if not slot_has_behaviour(slot, "bow") then
		cancel_draw()
	end
end

UserInputService.InputEnded:Connect(on_input_ended)
UserInputService.WindowFocusReleased:Connect(cancel_draw)
player.CharacterRemoving:Connect(cancel_draw)
tool_state.on_change:Connect(on_tool_changed)

return pull_bow
