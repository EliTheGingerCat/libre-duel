local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local editor_state = require(script.Parent.Parent.hud.editor_state)
local notification_management = require(script.Parent.Parent.notification_management)
local registry = require(script.Parent.Parent.hud.registry)

local function mount_queue_status(on_remove: (() -> ())?)
	local player = Players.LocalPlayer
	local screen = script.Parent.queue_status_template:Clone()
	screen.Name = "QueueStatus"
	local content = screen.content
	local options = script.Parent.mode_selector_template.window.body.mode_options.list
	local busy = false
	local timer: thread? = nil
	screen.Parent = player:WaitForChild("PlayerGui")

	local function update(): ()
		local mode = player:GetAttribute("QueueMode")
		local started_at = player:GetAttribute("QueueStartedAt")
		local queued = (mode == "solo" or mode == "duo") and typeof(started_at) == "number"
		screen.Enabled = queued or editor_state.enabled
		if not screen.Enabled then
			return
		end
		local elapsed = if typeof(started_at) == "number"
			then math.max(0, math.floor(workspace:GetServerTimeNow() - started_at))
			else 0
		local name = if mode == "duo" then "Duos" else "Solo"
		local teleporting = player:GetAttribute("QueueTeleporting") == true
		content.mode_info.Text = string.format(
			'%s\n<font color="rgb(180,180,180)"><font size="24">Mode: %s | Duration: %d:%02d</font></font>',
			if teleporting then "Teleporting..." else "Queueing...",
			name,
			math.floor(elapsed / 60),
			elapsed % 60
		)
		content.mode_icon.Image = if mode == "duo"
			then options.duo_button.icon.Image
			else options.solo_button.icon.Image
		content.cancel_button.Interactable = not busy and not teleporting and not editor_state.enabled
		content.cancel_button.Text = if busy then "Cancelling..." else "Cancel"
	end

	local function tick_status(): ()
		timer = nil
		update()
		if screen.Enabled then
			timer = task.delay(1, tick_status)
		end
	end

	local function on_status_changed(): ()
		if timer then
			task.cancel(timer)
			timer = nil
		end
		tick_status()
	end

	local function update_scale(): ()
		local size = screen.AbsoluteSize
		local factor = math.min(size.X / 1920, size.Y / 1080)
		content.scale.Scale = factor
		content.Position = UDim2.new(0.5, 0, 1, -10 - 130 * factor)
	end

	local function cancel(): ()
		if busy or editor_state.enabled or player:GetAttribute("QueueTeleporting") == true then
			return
		end
		busy = true
		update()
		local remote = ReplicatedStorage.remotes.leave_queue
		local ok, left = pcall(remote.InvokeServer, remote)
		busy = false
		if not ok or left ~= true then
			notification_management.add("Could not cancel the queue. Please try again.")
		end
		update()
	end

	local function create(remove: () -> ())
		return mount_queue_status(remove)
	end

	local connections = {
		player:GetAttributeChangedSignal("QueueMode"):Connect(on_status_changed),
		player:GetAttributeChangedSignal("QueueStartedAt"):Connect(on_status_changed),
		player:GetAttributeChangedSignal("QueueTeleporting"):Connect(on_status_changed),
		screen:GetPropertyChangedSignal("AbsoluteSize"):Connect(update_scale),
		content.cancel_button.Activated:Connect(cancel),
	}
	local unsubscribe_editor = editor_state.subscribe(on_status_changed)
	update_scale()
	local unregister = registry.register(content, screen, create, on_remove)
	on_status_changed()
	local active = true

	local function disconnect(): ()
		if not active then
			return
		end
		active = false
		unsubscribe_editor()
		for _, connection in connections do
			connection:Disconnect()
		end
		if timer then
			task.cancel(timer)
		end
		unregister()
		screen:Destroy()
	end
	return disconnect
end

return mount_queue_status
