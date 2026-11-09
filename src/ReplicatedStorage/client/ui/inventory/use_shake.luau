local GuiService = game:GetService("GuiService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local React = require(ReplicatedStorage.Packages.react)
local scale_animation_time = require(script.Parent.Parent.effects.scale_animation_time)

const DURATION = 0.35
const DISTANCE = 8
const FREQUENCY = 40

-- Returns a horizontal offset binding that shakes every time `trigger` changes.
local function use_shake(trigger: number)
	local offset, set_offset = React.useBinding(0)

	local function shake()
		local duration = scale_animation_time(DURATION)
		if trigger == 0 or GuiService.ReducedMotionEnabled or duration == 0 then
			return
		end
		local started = os.clock()
		local connection: RBXScriptConnection

		local function step(): ()
			const progress = (os.clock() - started) / duration
			if progress >= 1 then
				set_offset(0)
				connection:Disconnect()
				return
			end
			set_offset(math.sin(progress * DURATION * FREQUENCY) * DISTANCE * (1 - progress))
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
