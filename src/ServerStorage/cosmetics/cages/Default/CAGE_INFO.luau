const ReplicatedStorage = game:GetService("ReplicatedStorage")

const cage_data = require(ReplicatedStorage.shared.cosmetics.cage_data)

const CAGE_ROOT = script.Parent.cage

-- For now, these are unused: NAME, RARITY, CAGE_ICON.

const CAGE_DATA: cage_data.cage_data = {
    NAME = "Default",
    RARITY = "freebie",
    CAGE_ICON = 1231231,

    SPAWN = CAGE_ROOT.spawn,
    BOUNDS = CAGE_ROOT.bounds
}

return CAGE_DATA
