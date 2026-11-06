local ReplicatedStorage = game:GetService("ReplicatedStorage")

const COLOURS = require(ReplicatedStorage.shared.ui.COLOURS)
const HUD_DEFAULTS = require(script.Parent.Parent.hud.HUD_DEFAULTS)
local React = require(ReplicatedStorage.Packages.react)
local button = require(script.Parent.Parent.visuals.button)
local hud_screen = require(script.Parent.Parent.hud.hud_screen)
local mode_selector_state = require(script.Parent.mode_selector_state)
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

local function open_mode_selector(): ()
	mode_selector_state.set_enabled(true)
end

local function play_button(props: use_editable_hud.props)
	local content_ref = use_editable_hud(play_button, props)
	local state = use_queue_status()
	local editor_enabled = use_editor_enabled()
	local factor = use_viewport_scale()
	return create_element(
		hud_screen,
		{
			Name = "PlayButton",
			Enabled = editor_enabled or (not IS_RESERVED and state.mode == nil),
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
				icon = ICON,
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
