local players = game:GetService("Players")

local mount_combat = require(script.Parent.mount_combat)
local mount_fps = require(script.Parent.mount_fps)
local mount_input = require(script.Parent.mount_input)
local mount_paperdoll = require(script.Parent.mount_paperdoll)
local registry = require(script.Parent.registry)

const DEFAULTS: { [string]: { anchor: Vector2, position: UDim2 } } = {
	Keystrokes = { anchor = Vector2.one, position = UDim2.new(1, -12, 1, -178) },
	Mousestrokes = { anchor = Vector2.one, position = UDim2.new(1, -12, 1, -12) },
	ReachCounter = { anchor = Vector2.new(1, 0), position = UDim2.new(1, -12, 0, 63) },
	ComboCounter = { anchor = Vector2.new(1, 0), position = UDim2.new(1, -12, 0, 12) },
	FpsCounter = { anchor = Vector2.new(1, 0), position = UDim2.new(1, -12, 0, 114) },
	Paperdoll = { anchor = Vector2.new(0, 1), position = UDim2.new(0, 12, 1, -12) },
}

local function mount_content(name: string, content: Frame): () -> ()
	if name == "Keystrokes" then
		return mount_input(content, nil)
	elseif name == "Mousestrokes" then
		return mount_input(nil, content)
	end
	local main = content:FindFirstChild("Main")
	if name == "Paperdoll" then
		assert(main and main:IsA("ViewportFrame"))
		return mount_paperdoll(main)
	end
	assert(main and main:IsA("TextLabel"))
	if name == "FpsCounter" then
		return mount_fps(main)
	end
	return mount_combat(if name == "ReachCounter" then main else nil, if name == "ComboCounter" then main else nil)
end

local function create_builtin(name: string, on_remove: (() -> ())?): () -> ()
	local templates = script.Parent.templates
	local template = templates:FindFirstChild(if name == "FpsCounter" then "ComboCounter" else name)
	assert(template and template:IsA("ScreenGui"))
	local defaults = DEFAULTS[name]
	assert(defaults)
	local gui = template:Clone()
	gui.Name = name
	local content = gui:FindFirstChild("content")
	assert(content and content:IsA("Frame"))
	content.AnchorPoint = defaults.anchor
	content.Position = defaults.position
	local scale = Instance.new("UIScale")
	scale.Parent = content
	local player_gui = players.LocalPlayer:FindFirstChildOfClass("PlayerGui")
	assert(player_gui)
	gui.Parent = player_gui

	local function update_scale(): ()
		local size = gui.AbsoluteSize
		local factor = math.min(1, size.X / 900, size.Y / 700)
		scale.Scale = factor
		if name == "Keystrokes" then
			content.Position = UDim2.new(1, -12, 1, -12 - 166 * factor)
		elseif name == "ReachCounter" then
			content.Position = UDim2.new(1, -12, 0, 12 + 51 * factor)
		elseif name == "FpsCounter" then
			content.Position = UDim2.new(1, -12, 0, 12 + 102 * factor)
		end
	end

	local function create(remove: () -> ())
		return create_builtin(name, remove)
	end

	update_scale()
	local scale_connection = gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(update_scale)
	local disconnect_content = mount_content(name, content)
	local unregister = registry.register(content, gui, create, on_remove)
	local active = true

	local function disconnect(): ()
		if not active then
			return
		end
		active = false
		scale_connection:Disconnect()
		disconnect_content()
		unregister()
		gui:Destroy()
	end
	return disconnect
end

return create_builtin
