-- fits each upright pixel mesh into the sprite square items are drawn in
-- the meshes are flat in xy at 0.0442 studs per pixel, so scale is sprite units per stud of mesh
-- tools run corner to corner of their 16 pixel texture, about 21 pixels long
export type sprite_frame = {
	rotation: number,
	scale: number,
}

const PIXEL = 0.0442
const DIAGONAL_LENGTH = 21 / 16
-- these meshes have 3 to 4 times the pixels of a standard sprite, so at true size their detail reads tiny
const SIZE_MULTIPLIER = 1.75

const function fit_length(length_pixels: number): number
	return SIZE_MULTIPLIER * DIAGONAL_LENGTH / (length_pixels * PIXEL)
end

const SWORD: sprite_frame = { rotation = -45, scale = fit_length(47) }

const ITEM_SPRITE_FRAMES: { [string]: sprite_frame } = {
	sword = SWORD,
	arrow = SWORD,
	pickaxe = { rotation = -45, scale = fit_length(50) },
	-- the arrow in the draw meshes points right, the sprite has it pointing up and right
	bow = { rotation = 45, scale = fit_length(60) },
	cake = { rotation = 0, scale = SIZE_MULTIPLIER * (14 / 16) / (31 * PIXEL) },
}

return table.freeze({
	frames = ITEM_SPRITE_FRAMES,
	default = SWORD,
})
