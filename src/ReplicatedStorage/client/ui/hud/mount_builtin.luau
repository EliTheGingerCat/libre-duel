local mount_combat = require(script.Parent.mount_combat)
local mount_fps = require(script.Parent.mount_fps)
local mount_input = require(script.Parent.mount_input)
local mount_paperdoll = require(script.Parent.mount_paperdoll)

local function mount_builtin(name: string, content: Frame): () -> ()
	if name == "Keystrokes" then
		return mount_input(content, nil)
	elseif name == "Mousestrokes" then
		return mount_input(nil, content)
	end
	local main = content:FindFirstChild("Main")
	if name == "Paperdoll" then
		assert(main and main:IsA("ViewportFrame"))
		return mount_paperdoll(main)
	end
	assert(main and main:IsA("TextLabel"))
	if name == "FpsCounter" then
		return mount_fps(main)
	end
	return mount_combat(if name == "ReachCounter" then main else nil, if name == "ComboCounter" then main else nil)
end

return mount_builtin
