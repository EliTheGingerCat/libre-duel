const ContextActionService = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

const COLOURS = require(ReplicatedStorage.shared.ui.COLOURS)
const GAMEPAD_KEYBINDS = require(ReplicatedStorage.client.util.GAMEPAD_KEYBINDS)
const HUD_DEFAULTS = require(script.Parent.Parent.hud.HUD_DEFAULTS)
local React = require(ReplicatedStorage.Packages.react)
local button = require(script.Parent.Parent.visuals.button)
local hud_screen = require(script.Parent.Parent.hud.hud_screen)
local inventory_state = require(script.Parent.Parent.inventory.inventory_state)
local mode_selector_state = require(script.Parent.mode_selector_state)
const play_button_state = require(script.Parent.play_button_state)
const use_gamepad_glyph_image = require(script.Parent.Parent.glyphs.use_gamepad_glyph_image)
const use_input_device = require(script.Parent.Parent.visuals.use_input_device)
local use_editable_hud = require(script.Parent.Parent.hud.use_editable_hud)
local use_editor_enabled = require(script.Parent.Parent.hud.use_editor_enabled)
local use_queue_status = require(script.Parent.use_queue_status)
local use_viewport_scale = require(script.Parent.Parent.visuals.use_viewport_scale)

local create_element = React.createElement

const DEFAULTS = HUD_DEFAULTS.PlayButton
const ICON = "rbxassetid://114890369284583"
const SIZE = UDim2.fromOffset(280, 84)
-- Reserved servers host matches, so there is nothing to queue for.
const IS_RESERVED = game.PrivateServerId ~= "" and game.PrivateServerOwnerId == 0
const GAMEPAD_PLAY_ACTION = "play_button_gamepad"

const function open_mode_selector(): ()
	mode_selector_state.set_enabled(true)
end

const function open_mode_selector_from_gamepad(
	_action_name: string,
	input_state: Enum.UserInputState
): Enum.ContextActionResult
	if input_state ~= Enum.UserInputState.Begin then
		return Enum.ContextActionResult.Pass
	end
	if mode_selector_state.enabled then
		return Enum.ContextActionResult.Pass
	end
	open_mode_selector()
	return Enum.ContextActionResult.Sink
end

const function play_button(props: use_editable_hud.props)
	local content_ref = use_editable_hud(play_button, props)
	local state = use_queue_status()
	local editor_enabled = use_editor_enabled()
	local factor = use_viewport_scale()
	-- the glyph is white, so the button tints it green like the normal icon
	const play_glyph_image = use_gamepad_glyph_image(GAMEPAD_KEYBINDS.play)
	const is_gamepad = use_input_device() == "gamepad"
	local inventory_open, set_inventory_open = React.useState(inventory_state.enabled)

	const function subscribe()
		const function update(): ()
			set_inventory_open(inventory_state.enabled)
		end
		local connection = inventory_state.on_change:Connect(update)
		update()
		const function disconnect(): ()
			connection:Disconnect()
		end
		return disconnect
	end
	React.useEffect(subscribe, {})

	const available = not props.preview
		and not editor_enabled
		and not IS_RESERVED
		and state.mode == nil
		and not inventory_open

	const function bind_gamepad_play(): (() -> ())?
		if not available then
			return nil
		end
		play_button_state.set_available(true)
		ContextActionService:BindAction(
			GAMEPAD_PLAY_ACTION,
			open_mode_selector_from_gamepad,
			false,
			GAMEPAD_KEYBINDS.play
		)

		const function unbind(): ()
			play_button_state.set_available(false)
			ContextActionService:UnbindAction(GAMEPAD_PLAY_ACTION)
		end

		return unbind
	end
	React.useEffect(bind_gamepad_play, { available })

	return create_element(
		hud_screen,
		{
			Name = "PlayButton",
			Enabled = editor_enabled or (not IS_RESERVED and state.mode == nil and not inventory_open),
			ResetOnSpawn = false,
			preview = props.preview,
		},
		create_element("Frame", {
			ref = content_ref,
			Name = "content",
			AnchorPoint = if props.preview then Vector2.new(0.5, 0.5) else DEFAULTS.anchor,
			Position = if props.preview
				then UDim2.fromOffset(0, 0)
				else DEFAULTS.position + UDim2.fromOffset(0, DEFAULTS.stack_offset * factor),
			Size = SIZE,
			BackgroundTransparency = 1,
		}, {
			scale = create_element("UIScale", { Scale = factor }),
			button = create_element(button, {
				text = "Play!",
				icon = if is_gamepad and not props.preview then play_glyph_image else ICON,
				colour = COLOURS.success,
				radius = SIZE.Y.Offset / 2,
				size = SIZE,
				interactable = not editor_enabled and not props.preview,
				on_activated = open_mode_selector,
			}),
		})
	)
end

return play_button
