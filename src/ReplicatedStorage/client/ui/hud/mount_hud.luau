local players = game:GetService("Players")

local mount_combat = require(script.Parent.mount_combat)
local mount_input = require(script.Parent.mount_input)
local mount_paperdoll = require(script.Parent.mount_paperdoll)

type widget = {
	gui: ScreenGui,
	content: Frame,
	scale: UIScale,
}

local function create_widget(template: ScreenGui, anchor: Vector2, position: UDim2): widget
	local gui = template:Clone()
	local content = gui:FindFirstChild("content")
	assert(content and content:IsA("Frame"))
	content.AnchorPoint = anchor
	content.Position = position
	local scale = Instance.new("UIScale")
	scale.Parent = content
	return { gui = gui, content = content, scale = scale }
end

local function mount_hud()
	local templates = script.Parent.templates
	local keystrokes = create_widget(templates.Keystrokes, Vector2.one, UDim2.new(1, -12, 1, -178))
	local mousestrokes = create_widget(templates.Mousestrokes, Vector2.one, UDim2.new(1, -12, 1, -12))
	local reach = create_widget(templates.ReachCounter, Vector2.new(1, 0), UDim2.new(1, -12, 0, 63))
	local combo = create_widget(templates.ComboCounter, Vector2.new(1, 0), UDim2.new(1, -12, 0, 12))
	local paperdoll = create_widget(templates.Paperdoll, Vector2.new(0, 1), UDim2.new(0, 12, 1, -12))
	local widgets = { keystrokes, mousestrokes, reach, combo, paperdoll }
	local player_gui = players.LocalPlayer:FindFirstChildOfClass("PlayerGui")
	assert(player_gui)
	for _, widget in widgets do
		widget.gui.Parent = player_gui
	end

	local function update_scale(): ()
		local size = mousestrokes.gui.AbsoluteSize
		local scale = math.min(1, size.X / 900, size.Y / 700)
		for _, widget in widgets do
			widget.scale.Scale = scale
		end
		keystrokes.content.Position = UDim2.new(1, -12, 1, -12 - 166 * scale)
		reach.content.Position = UDim2.new(1, -12, 0, 12 + 51 * scale)
	end

	update_scale()
	local scale_connection = mousestrokes.gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(update_scale)
	local reach_label = reach.content:FindFirstChild("Main")
	local combo_label = combo.content:FindFirstChild("Main")
	local viewport = paperdoll.content:FindFirstChild("Main")
	assert(reach_label and reach_label:IsA("TextLabel"))
	assert(combo_label and combo_label:IsA("TextLabel"))
	assert(viewport and viewport:IsA("ViewportFrame"))
	local disconnect_input = mount_input(keystrokes.content, mousestrokes.content)
	local disconnect_combat = mount_combat(reach_label, combo_label)
	local disconnect_paperdoll = mount_paperdoll(viewport)

	local function disconnect(): ()
		scale_connection:Disconnect()
		disconnect_input()
		disconnect_combat()
		disconnect_paperdoll()
		for _, widget in widgets do
			widget.gui:Destroy()
		end
	end

	return disconnect
end

return mount_hud
