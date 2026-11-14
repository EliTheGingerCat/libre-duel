const sword_state = require(script.Parent.Parent.tools.sword.sword_state)
const VIEWMODEL_CONSTANTS = require(script.Parent.VIEWMODEL_CONSTANTS)

const function get_offset(): CFrame
	return if sword_state.blocking then VIEWMODEL_CONSTANTS.block_pose else CFrame.identity
end

return {
	get_offset = get_offset,
}
