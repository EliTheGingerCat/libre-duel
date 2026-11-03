local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.react)

local create_element = React.createElement

local function hud_screen(props: {
	preview: boolean?,
	children: unknown,
	Name: string,
	Enabled: boolean?,
	ResetOnSpawn: boolean?,
	ClipToDeviceSafeArea: boolean?,
})
	local ref = React.useRef(nil :: Frame?)
	local factor, set_factor = React.useBinding(1)
	local function fit_preview()
		local frame = ref.current
		if not frame then
			return
		end
		local content = frame:FindFirstChildWhichIsA("GuiObject")
		local parent = frame.Parent
		assert(content and parent and parent:IsA("GuiObject"))
		local function update(): ()
			local size = content.AbsoluteSize / math.max(0.001, factor:getValue())
			local available = parent.AbsoluteSize - Vector2.new(48, 24)
			set_factor(
				math.max(0.001, math.min(1, available.X / math.max(1, size.X), available.Y / math.max(1, size.Y)))
			)
		end
		local connection = parent:GetPropertyChangedSignal("AbsoluteSize"):Connect(update)
		local size_connection = content:GetPropertyChangedSignal("AbsoluteSize"):Connect(update)
		update()
		local function disconnect(): ()
			connection:Disconnect()
			size_connection:Disconnect()
		end
		return disconnect
	end
	React.useLayoutEffect(fit_preview, {})
	if props.preview then
		return create_element("Frame", {
			ref = ref,
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(0, 0),
		}, {
			scale = create_element("UIScale", { Scale = factor }),
			content = create_element(React.Fragment, {}, props.children),
		})
	end
	local screen_props = table.clone(props)
	screen_props.preview = nil
	screen_props.children = nil
	return create_element("ScreenGui", screen_props, {
		widget = create_element("Frame", {
			Name = "hud_widget",
			BackgroundTransparency = 1,
			Size = UDim2.fromOffset(0, 0),
		}, {
			scale = create_element("UIScale"),
			content = create_element(React.Fragment, {}, props.children),
		}),
	})
end

return hud_screen
