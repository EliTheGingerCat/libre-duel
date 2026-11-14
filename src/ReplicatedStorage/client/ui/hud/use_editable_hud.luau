local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.react)
local ReactRoblox = require(ReplicatedStorage.Packages["react-roblox"])
local registry = require(script.Parent.registry)

type content_ref = { current: GuiObject? }
export type props = { on_remove: (() -> ())?, preview: boolean? }

const function use_editable_hud(component: (props) -> unknown, props: props, default_hidden: boolean?): content_ref
	local ref: content_ref = React.useRef(nil)
	-- Registration happens once, so read on_remove through a ref to always call the latest one.
	local on_remove_ref = React.useRef(props.on_remove)
	on_remove_ref.current = props.on_remove
	const function call_on_remove(): ()
		local on_remove = on_remove_ref.current
		if on_remove then
			on_remove()
		end
	end
	const function register_content()
		if props.preview then
			return
		end
		local content = ref.current
		if not content then
			return
		end
		local screen = content:FindFirstAncestorOfClass("ScreenGui")
		assert(screen and screen:IsA("ScreenGui"))
		local player_gui = screen.Parent
		assert(player_gui and player_gui:IsA("PlayerGui"))
		const function create(on_remove: () -> ())
			local container = Instance.new("Folder")
			local tree = ReactRoblox.createRoot(container)
			local active = true
			const function disconnect(): ()
				if not active then
					return
				end
				active = false
				tree:unmount()
				container:Destroy()
			end
			tree:render(ReactRoblox.createPortal(React.createElement(component, { on_remove = on_remove }), player_gui))
			return disconnect
		end
		const function render_preview()
			return React.createElement(component, { preview = true })
		end
		return registry.register(
			content,
			screen,
			create,
			if props.on_remove then call_on_remove else nil,
			render_preview,
			default_hidden
		)
	end
	-- Restore the native parent before React removes its host instances.
	React.useLayoutEffect(register_content, {})
	return ref
end

return use_editable_hud
