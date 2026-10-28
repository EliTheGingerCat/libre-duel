local replicated_storage = game:GetService("ReplicatedStorage")

local react = require(replicated_storage.Packages.react)
local registry = require(script.Parent.registry)

type content_ref = { current: GuiObject? }

local function use_editable_hud(): content_ref
	local ref: content_ref = react.useRef(nil)
	local function register_content()
		local content = ref.current
		if not content then
			return
		end
		local screen = content:FindFirstAncestorOfClass("ScreenGui")
		assert(screen and screen:IsA("ScreenGui"))
		return registry.register(content, screen)
	end
	-- Restore the native parent before React removes its host instances.
	react.useLayoutEffect(register_content, {})
	return ref
end

return use_editable_hud
