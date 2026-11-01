local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.react)
local counter = require(script.Parent.counter)
local hud_screen = require(script.Parent.hud_screen)
local keystrokes = require(script.Parent.keystrokes)
local mount_builtin = require(script.Parent.mount_builtin)
local mousestrokes = require(script.Parent.mousestrokes)
local use_editable_hud = require(script.Parent.use_editable_hud)

local create_element = React.createElement

const DEFAULTS = {
	Keystrokes = { size = Vector2.new(152, 137), anchor = Vector2.one, position = UDim2.new(1, -12, 1, -178) },
	Mousestrokes = { size = Vector2.new(224, 158), anchor = Vector2.one, position = UDim2.new(1, -12, 1, -12) },
	ReachCounter = { size = Vector2.new(168, 42), anchor = Vector2.new(1, 0), position = UDim2.new(1, -12, 0, 63) },
	ComboCounter = { size = Vector2.new(168, 42), anchor = Vector2.new(1, 0), position = UDim2.new(1, -12, 0, 12) },
	FpsCounter = { size = Vector2.new(168, 42), anchor = Vector2.new(1, 0), position = UDim2.new(1, -12, 0, 114) },
	Paperdoll = { size = Vector2.new(128, 210), anchor = Vector2.new(0, 1), position = UDim2.new(0, 12, 1, -12) },
}

type props = use_editable_hud.props & { name: string }

local function builtin(props: props)
	local function copy(copy_props: use_editable_hud.props)
		return create_element(
			builtin,
			{ name = props.name, on_remove = copy_props.on_remove, preview = copy_props.preview }
		)
	end
	local ref = use_editable_hud(copy, props)
	local defaults = DEFAULTS[props.name]
	assert(defaults)
	local factor, set_factor = React.useBinding(1)

	local function mount_content(): (() -> ())?
		local content = ref.current
		assert(content and content:IsA("Frame"))
		if props.preview then
			if props.name == "Paperdoll" then
				return mount_builtin(props.name, content)
			end
			return nil
		end
		local screen = content:FindFirstAncestorOfClass("ScreenGui")
		local scale = content:FindFirstChildOfClass("UIScale")
		assert(screen and scale)
		local function update_scale(): ()
			local size = screen.AbsoluteSize
			set_factor(math.min(1, size.X / 900, size.Y / 700))
		end
		local connection = screen:GetPropertyChangedSignal("AbsoluteSize"):Connect(update_scale)
		update_scale()
		local cleanup = mount_builtin(props.name, content)
		local function disconnect(): ()
			connection:Disconnect()
			cleanup()
		end
		return disconnect
	end
	React.useLayoutEffect(mount_content, {})

	local function position(value: number): UDim2
		if props.name == "Keystrokes" then
			return UDim2.new(1, -12, 1, -12 - 166 * value)
		elseif props.name == "ReachCounter" then
			return UDim2.new(1, -12, 0, 12 + 51 * value)
		elseif props.name == "FpsCounter" then
			return UDim2.new(1, -12, 0, 12 + 102 * value)
		end
		return defaults.position
	end
	local child = if props.name == "Keystrokes"
		then create_element(keystrokes)
		elseif props.name == "Mousestrokes" then create_element(mousestrokes)
		elseif props.name == "Paperdoll" then create_element(
			"ViewportFrame",
			{ Name = "Main", Size = UDim2.fromOffset(defaults.size.X, defaults.size.Y), BackgroundTransparency = 1 }
		)
		else create_element(counter, { name = props.name })
	return create_element(
		hud_screen,
		{ Name = props.name, ResetOnSpawn = false, preview = props.preview },
		create_element("Frame", {
			ref = ref,
			Name = "content",
			Size = UDim2.fromOffset(defaults.size.X, defaults.size.Y),
			BackgroundTransparency = 1,
			AnchorPoint = if props.preview then Vector2.new(0.5, 0.5) else defaults.anchor,
			Position = if props.preview then UDim2.fromOffset(0, 0) else factor:map(position),
		}, { scale = create_element("UIScale", { Scale = factor }), content = child })
	)
end

return builtin
