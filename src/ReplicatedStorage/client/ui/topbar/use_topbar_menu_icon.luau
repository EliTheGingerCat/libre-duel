const ContextActionService = game:GetService("ContextActionService")
const ReplicatedStorage = game:GetService("ReplicatedStorage")
const UserInputService = game:GetService("UserInputService")

const GAMEPAD_KEYBINDS = require(ReplicatedStorage.client.util.GAMEPAD_KEYBINDS)
const React = require(ReplicatedStorage.Packages.react)
const editor_state = require(script.Parent.Parent.hud.editor_state)
const topbarplus = require(ReplicatedStorage.Packages.topbarplus)

type icon_handle = {
	select: (icon_handle) -> icon_handle,
	deselect: (icon_handle) -> icon_handle,
	setEnabled: (icon_handle, boolean) -> icon_handle,
}

export type topbar_menu_icon = {
	enabled: boolean,
	close: () -> (),
}

-- a topbar button that opens a menu, closed by escape or the gamepad close button and hidden while the hud editor is open
const function use_topbar_menu_icon(name: string, image: string): topbar_menu_icon
	const enabled, set_enabled = React.useState(false)
	const icon_ref = React.useRef(nil :: icon_handle?)

	const function mount(): () -> ()
		const icon = topbarplus.new():setName(name):setImage(image):setCaption(name):align("Left")
		icon_ref.current = icon
		local menu_open = false
		local return_to_menu = false
		const function open(): ()
			menu_open = true
			set_enabled(true)
		end
		const function close(): ()
			menu_open = false
			set_enabled(false)
		end
		const function close_on_escape(input: InputObject, processed: boolean): ()
			if not processed and input.KeyCode == Enum.KeyCode.Escape then
				icon:deselect()
			end
		end
		-- leaving the editor reopens the menu if the editor was opened while it was showing
		const function editor_changed(): ()
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
		const unsubscribe_editor = editor_state.subscribe(editor_changed)
		const connections = {
			icon.selected:Connect(open),
			icon.deselected:Connect(close),
			UserInputService.InputBegan:Connect(close_on_escape),
		}
		const function disconnect(): ()
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

	const function close(): ()
		if icon_ref.current then
			icon_ref.current:deselect()
		end
	end

	-- bound through ContextActionService so it wins over gamepad ui navigation, which would otherwise take B to deselect
	const function bind_gamepad_close(): (() -> ())?
		if not enabled then
			return nil
		end
		const action_name = `{name}_menu_gamepad_close`
		const function close_from_gamepad(
			_action_name: string,
			input_state: Enum.UserInputState
		): Enum.ContextActionResult
			if input_state == Enum.UserInputState.Begin then
				close()
			end
			return Enum.ContextActionResult.Sink
		end
		ContextActionService:BindActionAtPriority(
			action_name,
			close_from_gamepad,
			false,
			Enum.ContextActionPriority.High.Value,
			GAMEPAD_KEYBINDS.menu_close
		)
		const function unbind(): ()
			ContextActionService:UnbindAction(action_name)
		end
		return unbind
	end
	React.useEffect(bind_gamepad_close, { enabled })

	return { enabled = enabled, close = close }
end

return use_topbar_menu_icon
