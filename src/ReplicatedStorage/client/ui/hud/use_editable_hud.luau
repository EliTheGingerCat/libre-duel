local replicated_storage = game:GetService("ReplicatedStorage")

local react = require(replicated_storage.Packages.react)
local react_roblox = require(replicated_storage.Packages["react-roblox"])
local registry = require(script.Parent.registry)

type content_ref = { current: GuiObject? }
export type props = { on_remove: (() -> ())? }

local function use_editable_hud(component: (props) -> unknown, props: props): content_ref
	local ref: content_ref = react.useRef(nil)
	local function register_content()
		local content = ref.current
		if not content then
			return
		end
		local screen = content:FindFirstAncestorOfClass("ScreenGui")
		assert(screen and screen:IsA("ScreenGui"))
		local player_gui = screen.Parent
		assert(player_gui and player_gui:IsA("PlayerGui"))
		local function create(on_remove: () -> ())
			local container = Instance.new("Folder")
			local tree = react_roblox.createRoot(container)
			local active = true
			local function disconnect(): ()
				if not active then
					return
				end
				active = false
				tree:unmount()
				container:Destroy()
			end
			tree:render(
				react_roblox.createPortal(react.createElement(component, { on_remove = on_remove }), player_gui)
			)
			return disconnect
		end
		return registry.register(content, screen, create, props.on_remove)
	end
	-- Restore the native parent before React removes its host instances.
	react.useLayoutEffect(register_content, {})
	return ref
end

return use_editable_hud
