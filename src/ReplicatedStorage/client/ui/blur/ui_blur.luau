local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.react)
local use_setting = require(script.Parent.Parent.settings.use_setting)

local active = 0

-- Blurs the parent GuiObject while the setting is on.
local function ui_blur()
	local enabled = use_setting("ui_blur") == true
	local ref = React.useRef(nil :: Folder?)
	local function mount()
		local folder = ref.current
		local target = if folder then folder.Parent else nil
		if not enabled or not target or not target:IsA("GuiObject") then
			return
		end
		-- Requiring the module adds a DepthOfFieldEffect to Lighting, so wait until the setting is on.
		local UIBlur = require(script.Parent.UIBlur)
		local blur = UIBlur.new(target)
		active += 1
		UIBlur.DepthOfField.Enabled = true
		local function destroy(): ()
			blur:Destroy()
			active -= 1
			UIBlur.DepthOfField.Enabled = active > 0
		end
		return destroy
	end
	React.useLayoutEffect(mount, { enabled })
	return React.createElement("Folder", { ref = ref, Name = "ui_blur" })
end

return ui_blur
