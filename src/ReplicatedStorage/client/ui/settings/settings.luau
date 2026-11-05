local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local React = require(ReplicatedStorage.Packages.react)
local editor_state = require(script.Parent.Parent.hud.editor_state)
local settings_definitions = require(script.Parent.settings_definitions)
local settings_menu = require(script.Parent.settings_menu)
local topbarplus = require(ReplicatedStorage.Packages.topbarplus)

settings_definitions()

type icon_handle = { deselect: (icon_handle) -> icon_handle }

local function settings()
	local enabled, set_enabled = React.useState(false)
	local icon_ref = React.useRef(nil :: icon_handle?)
	local function mount()
		local icon = topbarplus
			.new()
			:setName("Settings")
			:setImage("rbxassetid://104330757164550")
			:setCaption("Settings")
			:align("Left")
		icon_ref.current = icon
		local menu_open = false
		local return_to_menu = false
		local function open(): ()
			menu_open = true
			set_enabled(true)
		end
		local function close(): ()
			menu_open = false
			set_enabled(false)
		end
		local function key(input: InputObject, processed: boolean): ()
			if not processed and (input.KeyCode == Enum.KeyCode.Escape or input.KeyCode == Enum.KeyCode.ButtonB) then
				icon:deselect()
			end
		end
		-- The menu and the HUD editor never show together. Leaving the editor returns to the menu if it was open.
		local function editor_changed(): ()
			if editor_state.enabled then
				return_to_menu = menu_open
				icon:deselect()
				icon:setEnabled(false)
			else
				icon:setEnabled(true)
				if return_to_menu then
					return_to_menu = false
					icon:select()
				end
			end
		end
		local unsubscribe_editor = editor_state.subscribe(editor_changed)
		local connections =
			{ icon.selected:Connect(open), icon.deselected:Connect(close), UserInputService.InputBegan:Connect(key) }
		local function disconnect(): ()
			unsubscribe_editor()
			for _, connection in connections do
				connection:Disconnect()
			end
			icon:destroy()
			icon_ref.current = nil
		end
		return disconnect
	end
	React.useEffect(mount, {})
	local function close(): ()
		if icon_ref.current then
			icon_ref.current:deselect()
		end
		set_enabled(false)
	end
	return React.createElement(settings_menu, { enabled = enabled, on_close = close })
end

return settings
