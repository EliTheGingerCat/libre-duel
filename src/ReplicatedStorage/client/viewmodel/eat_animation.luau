const cake_state = require(script.Parent.Parent.tools.cake.cake_state)
const VIEWMODEL_CONSTANTS = require(script.Parent.VIEWMODEL_CONSTANTS)

const TWO_PI = 2 * math.pi

local phase = 0
local amount = 0

local function get_offset(delta_time: number): CFrame
    const target = if cake_state.eating then 1 else 0
    amount += (target - amount) * (1 - math.exp(-VIEWMODEL_CONSTANTS.eat_smoothing * delta_time))
    phase = (phase + VIEWMODEL_CONSTANTS.eat_bob_speed * delta_time) % TWO_PI

    return CFrame.identity:Lerp(VIEWMODEL_CONSTANTS.eat_pose, amount)
        * CFrame.new(0, math.sin(phase) * VIEWMODEL_CONSTANTS.eat_bob_height * amount, 0)
end

return {
    get_offset = get_offset,
}
