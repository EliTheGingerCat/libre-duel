const VIEWMODEL_CONSTANTS = require(script.Parent.VIEWMODEL_CONSTANTS)

local is_blocking: boolean = false

local function set_blocking(blocking: boolean): ()
    is_blocking = blocking
end

local function get_offset(): CFrame
    return if is_blocking then VIEWMODEL_CONSTANTS.block_pose else CFrame.identity
end

return {
    set_blocking = set_blocking,
    get_offset = get_offset,
}
