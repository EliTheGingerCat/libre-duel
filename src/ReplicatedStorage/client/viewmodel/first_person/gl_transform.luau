-- a tiny stand in for the GL matrix stack the item transforms are written against
-- every scale the renderer applies is uniform, so it is kept as one number next to the rigid part
export type gl_transform = {
	cframe: CFrame,
	scale: number,
}

const function new_gl_transform(): gl_transform
	return { cframe = CFrame.identity, scale = 1 }
end

const function translate(transform: gl_transform, x: number, y: number, z: number): ()
	transform.cframe *= CFrame.new(x * transform.scale, y * transform.scale, z * transform.scale)
end

-- same convention as GlStateManager.rotate, degrees around an axis
const function rotate(transform: gl_transform, degrees: number, x: number, y: number, z: number): ()
	transform.cframe *= CFrame.fromAxisAngle(Vector3.new(x, y, z), math.rad(degrees))
end

const function scale(transform: gl_transform, amount: number): ()
	transform.scale *= amount
end

return {
	new = new_gl_transform,
	translate = translate,
	rotate = rotate,
	scale = scale,
}
