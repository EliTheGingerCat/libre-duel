const ContentProvider = game:GetService("ContentProvider")
const ReplicatedStorage = game:GetService("ReplicatedStorage")

const bow_state = require(script.Parent.Parent.tools.bow.bow_state)
const mesh_display = require(script.Parent.mesh_display)
const tool_types = require(ReplicatedStorage.shared.tools.tool_types)
const VIEWMODEL_CONSTANTS = require(script.Parent.VIEWMODEL_CONSTANTS)

const preloaded: { [{ tool_types.bow_draw_frame }]: true } = {}

-- nil while showing the undrawn bow
local shown_frame: tool_types.bow_draw_frame? = nil

-- assets that haven't loaded yet would flicker when the draw first reaches them
const function preload(draw_frames: { tool_types.bow_draw_frame }): ()
    if preloaded[draw_frames] then
        return
    end
    preloaded[draw_frames] = true

    const assets: { string } = {}
    for _, frame in draw_frames do
        table.insert(assets, frame.mesh)
        table.insert(assets, frame.texture)
    end
    task.spawn(ContentProvider.PreloadAsync, ContentProvider, assets)
end

const function get_draw_frame(
    draw_frames: { tool_types.bow_draw_frame },
    draw_started: number
): tool_types.bow_draw_frame
    const progress = math.min((os.clock() - draw_started) / VIEWMODEL_CONSTANTS.bow_full_draw_seconds + .3, 1)
    return draw_frames[math.floor(progress * (#draw_frames - 1)) + 1]
end

const function show(tool: tool_types.tool): ()
    shown_frame = nil
    mesh_display.show(tool)

    const bow = tool.behaviours.bow
    if bow ~= nil and bow.draw_frames ~= nil then
        preload(bow.draw_frames)
    end
end

const function update(tool: tool_types.tool): ()
    const bow = tool.behaviours.bow
    const draw_frames = if bow ~= nil then bow.draw_frames else nil
    if draw_frames == nil or #draw_frames == 0 then
        return
    end

    const draw_started = bow_state.draw_started
    const frame = if draw_started ~= nil then get_draw_frame(draw_frames, draw_started) else nil
    if frame == shown_frame then
        return
    end

    shown_frame = frame
    if frame == nil then
        mesh_display.show(tool)
    else
        mesh_display.set_mesh(frame.mesh)
        mesh_display.set_texture(frame.texture)
    end
end

return {
    show = show,
    hide = mesh_display.hide,
    get_part = mesh_display.get_part,
    set_transparency = mesh_display.set_transparency,
    update = update,
}
