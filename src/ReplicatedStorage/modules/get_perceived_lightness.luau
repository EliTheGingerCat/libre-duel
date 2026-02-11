-- Perceived lightness is basically how light a colour is according to the human eye.
-- Used mathematics from: <https://stackoverflow.com/a/56678483>

local function sRGB_to_linear(colour_channel: number): number
    if colour_channel <= 0.04045 then
        return colour_channel / 12.92
    else
        return math.pow((colour_channel + 0.055) / 1.055, 2.4)
    end
end

local function Color3_to_luminance(colour: Color3): number
    local luminance = (
          0.2126 * sRGB_to_linear(colour.R)
        + 0.7152 * sRGB_to_linear(colour.G)
        + 0.0722 * sRGB_to_linear(colour.B)
    )
    return luminance
end

local function luminance_to_perceived_lightness(luminance: number): number
    if luminance <= 216 / 24389 then
        return luminance * (24389 / 27)
    else
        return math.pow(luminance, 1/3) * 116 - 16
    end
end

--- @return number -- ranges from 0 (pitch black) to 100 (fully white)
local function get_perceived_lightness(colour: Color3): number
    local luminance = Color3_to_luminance(colour)
    local perceived_lightness = luminance_to_perceived_lightness(luminance)
    return perceived_lightness
end

return get_perceived_lightness
