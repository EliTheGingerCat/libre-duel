-- a part's transparency doesn't reach its textures, so textured cubes need both set
local function set_cube_transparency(cube: BasePart, transparency: number): ()
	cube.Transparency = transparency
	for _, child in cube:GetChildren() do
		if child:IsA("Texture") then
			child.Transparency = transparency
		end
	end
end

return set_cube_transparency
