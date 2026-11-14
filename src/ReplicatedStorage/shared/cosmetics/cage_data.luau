local cosmetic_rarities = require(script.Parent.cosmetic_rarities)

export type cage_data = {
    NAME: string,
    RARITY: cosmetic_rarities.cosmetic_rarities,
    CAGE_ICON: number,

    SPAWN: BasePart,
    BOUNDS: BasePart,
}

return {}
