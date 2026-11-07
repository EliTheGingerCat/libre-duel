const TweenService = game:GetService("TweenService")

const VIEWMODEL_CONSTANTS = require(script.Parent.VIEWMODEL_CONSTANTS)

-- tweens need an instance property, and the handler overwrites the part's CFrame every frame
const progress = Instance.new("NumberValue")
const tween = TweenService:Create(progress, VIEWMODEL_CONSTANTS.swing_tween_info, { Value = 1 })

local function play(): ()
    if tween.PlaybackState == Enum.PlaybackState.Playing then
        return
    end
    tween:Play()
end

local function get_offset(): CFrame
    return CFrame.identity:Lerp(VIEWMODEL_CONSTANTS.swing_pose, progress.Value)
end

return {
    play = play,
    get_offset = get_offset,
}
