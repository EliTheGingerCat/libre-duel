local GuiService = game:GetService("GuiService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local React = require(ReplicatedStorage.Packages.react)

const DURATION = 0.35
const DISTANCE = 8
const FREQUENCY = 40

-- Returns a horizontal offset binding that shakes every time `trigger` changes.
local function use_shake(trigger: number)
	local offset, set_offset = React.useBinding(0)

	local function shake()
		if trigger == 0 or GuiService.ReducedMotionEnabled then
			return
		end
		local started = os.clock()
		local connection: RBXScriptConnection

		local function step(): ()
			const elapsed = os.clock() - started
			if elapsed >= DURATION then
				set_offset(0)
				connection:Disconnect()
				return
			end
			set_offset(math.sin(elapsed * FREQUENCY) * DISTANCE * (1 - elapsed / DURATION))
		end

		connection = RunService.RenderStepped:Connect(step)

		local function disconnect(): ()
			connection:Disconnect()
			set_offset(0)
		end

		return disconnect
	end

	React.useEffect(shake, { trigger })

	return offset
end

return use_shake
