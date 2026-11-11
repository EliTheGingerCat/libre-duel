local ReplicatedStorage = game:GetService("ReplicatedStorage")

const HUD_DEFAULTS = require(script.Parent.HUD_DEFAULTS)
local React = require(ReplicatedStorage.Packages.react)
local get_reference_resolution = require(script.Parent.Parent.visuals.REFERENCE_RESOLUTIONS)
local input_device = require(ReplicatedStorage.client.util.input_device)
local tween_number = require(script.Parent.Parent.effects.tween_number)
local counter = require(script.Parent.counter)
local hud_screen = require(script.Parent.hud_screen)
local keystrokes = require(script.Parent.keystrokes)
local mount_builtin = require(script.Parent.mount_builtin)
local mousestrokes = require(script.Parent.mousestrokes)
local use_editable_hud = require(script.Parent.use_editable_hud)

local create_element = React.createElement

-- Switching devices wobbles the widget into its new size instead of snapping.
const DEVICE_TWEEN = TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

type props = use_editable_hud.props & { name: string }

local function builtin(props: props)
	local function copy(copy_props: use_editable_hud.props)
		return create_element(
			builtin,
			{ name = props.name, on_remove = copy_props.on_remove, preview = copy_props.preview }
		)
	end
	local defaults = HUD_DEFAULTS[props.name]
	assert(defaults)
	local ref = use_editable_hud(copy, props, defaults.hidden)
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
		local cancel_tween: (() -> ())? = nil
		local function stop_tween(): ()
			if cancel_tween then
				cancel_tween()
				cancel_tween = nil
			end
		end
		local function get_target(): number
			local size = screen.AbsoluteSize
			local reference = get_reference_resolution("shrink", input_device.current)
			return math.min(1, size.X / reference.X, size.Y / reference.Y)
		end
		local function update_scale(): ()
			stop_tween()
			set_factor(get_target())
		end
		local function on_device_changed(): ()
			stop_tween()
			cancel_tween = tween_number(factor:getValue(), get_target(), DEVICE_TWEEN, set_factor)
		end
		local connection = screen:GetPropertyChangedSignal("AbsoluteSize"):Connect(update_scale)
		local device_connection = input_device.changed:Connect(on_device_changed)
		update_scale()
		local cleanup = mount_builtin(props.name, content)
		local function disconnect(): ()
			connection:Disconnect()
			device_connection:Disconnect()
			stop_tween()
			cleanup()
		end
		return disconnect
	end
	React.useLayoutEffect(mount_content, {})

	local function position(value: number): UDim2
		return defaults.position + UDim2.fromOffset(0, (defaults.stack_offset or 0) * value)
	end
	local child = if props.name == "Keystrokes"
		then create_element(keystrokes, { preview = props.preview })
		elseif props.name == "Mousestrokes" then create_element(mousestrokes, { preview = props.preview })
		elseif props.name == "Paperdoll" then create_element(
			"ViewportFrame",
			{ Name = "Main", Size = UDim2.fromOffset(defaults.size.X, defaults.size.Y), BackgroundTransparency = 1 }
		)
		else create_element(counter, { name = props.name, preview = props.preview })
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
