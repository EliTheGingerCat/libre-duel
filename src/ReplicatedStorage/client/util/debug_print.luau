local UserInputService = game:GetService("UserInputService")

const KEYBINDS = require(script.Parent.KEYBINDS)

local debug_enabled = true

local function debug_print(...: any): ()
	if debug_enabled then
		local source = debug.info(2, "s")
		print(source, ...)
	end
end

local function on_input_began(input: InputObject): ()
	if input.KeyCode == KEYBINDS.debug_local then
		debug_enabled = not debug_enabled

		if debug_enabled then
			print("Enabled debug printing.")
		else
			print("Disabled debug printing.")
		end
	end
end

UserInputService.InputBegan:Connect(on_input_began)

return debug_print
