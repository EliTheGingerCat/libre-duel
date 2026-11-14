local ReplicatedStorage = game:GetService("ReplicatedStorage")

const HUD_DEFAULTS = require(script.Parent.HUD_DEFAULTS)
const TOUCH_ACTIONS = require(script.Parent.touch_actions)
local React = require(ReplicatedStorage.Packages.react)
local animated_button = require(script.Parent.Parent.visuals.animated_button)
local button_motion = require(script.Parent.Parent.visuals.button_motion)
local editor_state = require(script.Parent.editor_state)
local hide_stock_jump = require(script.Parent.hide_stock_jump)
local hud_screen = require(script.Parent.hud_screen)
local use_editable_hud = require(script.Parent.use_editable_hud)

local create_element = React.createElement

-- The jump icon is cut out of Roblox's own touch controls sheet, the rest are custom.
const ICONS: { [string]: { image: string, rect_offset: Vector2?, rect_size: Vector2? } } = {
	JumpButton = {
		image = "rbxasset://textures/ui/Input/TouchControlsSheetV2.png",
		rect_offset = Vector2.new(1, 146),
		rect_size = Vector2.new(144, 144),
	},
	AttackButton = { image = "rbxassetid://124110822665522" },
	UseItemButton = { image = "rbxassetid://87849979795935" },
	InventoryButton = { image = "rbxassetid://91366813808766" },
	TablistButton = { image = "rbxassetid://87450204673643" },
}

type props = use_editable_hud.props & { name: string }

const function touch_button(props: props)
	const function copy(copy_props: use_editable_hud.props)
		return create_element(
			touch_button,
			{ name = props.name, on_remove = copy_props.on_remove, preview = copy_props.preview }
		)
	end
	local defaults = HUD_DEFAULTS[props.name]
	const action = TOUCH_ACTIONS[props.name]
	const icon = ICONS[props.name]
	assert(defaults and action and icon)
	local ref = use_editable_hud(copy, props, defaults.hidden)
	local holding = React.useRef(false)

	-- Fires on the finger going down, not on lifting it like Activated, since these are held like keys.
	const function press(): ()
		if props.preview or editor_state.enabled or holding.current then
			return
		end
		holding.current = true
		action.press()
	end
	const function release(): ()
		if holding.current then
			holding.current = false
			action.release()
		end
	end
	const function mount(): (() -> ())?
		if props.preview then
			return nil
		end
		local content = ref.current
		local detector = if content then content:FindFirstChildWhichIsA("UIDragDetector", true) else nil
		assert(detector)
		local connections = { detector.DragStart:Connect(press), detector.DragEnd:Connect(release) }
		local disconnect_editor = editor_state.subscribe(release)
		local unhide_stock: (() -> ())? = nil
		if props.name == "JumpButton" then
			local screen = if content then content:FindFirstAncestorOfClass("ScreenGui") else nil
			local player_gui = if screen then screen.Parent else nil
			if player_gui and player_gui:IsA("PlayerGui") then
				unhide_stock = hide_stock_jump(player_gui)
			end
		end
		const function cleanup(): ()
			release()
			disconnect_editor()
			for _, connection in connections do
				connection:Disconnect()
			end
			if unhide_stock then
				unhide_stock()
			end
		end
		return cleanup
	end
	React.useLayoutEffect(mount, {})

	return create_element(
		hud_screen,
		{ Name = props.name, ResetOnSpawn = false, preview = props.preview },
		create_element("Frame", {
			ref = ref,
			Name = "content",
			Size = UDim2.fromOffset(defaults.size.X, defaults.size.Y),
			BackgroundTransparency = 1,
			AnchorPoint = if props.preview then Vector2.new(0.5, 0.5) else defaults.anchor,
			Position = if props.preview then UDim2.fromOffset(0, 0) else defaults.position,
		}, {
			button = create_element(animated_button, {
				class_name = "ImageButton",
				Name = "Main",
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				Image = icon.image,
				ImageRectOffset = icon.rect_offset or Vector2.zero,
				ImageRectSize = icon.rect_size or Vector2.zero,
			}, {
				feedback = create_element(button_motion, { animate_colour = false }),
			}),
		})
	)
end

return touch_button
