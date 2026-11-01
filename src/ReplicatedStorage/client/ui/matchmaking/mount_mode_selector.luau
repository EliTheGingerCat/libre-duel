local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local editor_state = require(script.Parent.Parent.hud.editor_state)
local mode_selector_state = require(script.Parent.mode_selector_state)
local notification_management = require(script.Parent.Parent.notification_management)

local function mount_mode_selector()
	local player = Players.LocalPlayer
	local screen = script.Parent.mode_selector_template:Clone()
	screen.Name = "ModeSelector"
	local window = screen.window
	local list = window.body.mode_options.list
	local busy = false
	screen.Parent = player:WaitForChild("PlayerGui")

	local function update(): ()
		screen.Enabled = mode_selector_state.enabled and not editor_state.enabled
		list.solo_button.Interactable = not busy
		list.duo_button.Interactable = not busy
	end

	local function update_scale(): ()
		local size = screen.AbsoluteSize
		window.scale.Scale = math.min(1, size.X / 1920, size.Y / 1080)
	end

	local function close(): ()
		mode_selector_state.set_enabled(false)
	end

	local function join(mode: "solo" | "duo"): ()
		if busy then
			return
		end
		if RunService:IsStudio() then
			notification_management.add("Matchmaking is unavailable in Studio.")
			return
		end
		busy = true
		update()
		local ok, joined =
			pcall(ReplicatedStorage.remotes.join_queue.InvokeServer, ReplicatedStorage.remotes.join_queue, mode)
		busy = false
		if ok and joined == true then
			close()
		else
			notification_management.add("Could not join the queue. Please try again.")
		end
		update()
	end

	local function join_solo(): ()
		join("solo")
	end

	local function join_duo(): ()
		join("duo")
	end

	local function on_input(input: InputObject, game_processed: boolean): ()
		if not game_processed and input.KeyCode == Enum.KeyCode.Escape then
			close()
		end
	end

	local function on_editor_changed(): ()
		if editor_state.enabled then
			close()
		end
	end

	local connections = {
		mode_selector_state.on_change:Connect(update),
		screen:GetPropertyChangedSignal("AbsoluteSize"):Connect(update_scale),
		window.close_button.Activated:Connect(close),
		screen.background.Activated:Connect(close),
		list.solo_button.Activated:Connect(join_solo),
		list.duo_button.Activated:Connect(join_duo),
		UserInputService.InputBegan:Connect(on_input),
	}
	local unsubscribe_editor = editor_state.subscribe(on_editor_changed)
	update_scale()
	update()

	local function disconnect(): ()
		close()
		unsubscribe_editor()
		for _, connection in connections do
			connection:Disconnect()
		end
		screen:Destroy()
	end
	return disconnect
end

return mount_mode_selector
