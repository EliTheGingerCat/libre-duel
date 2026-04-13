local serialiser = {}

-- encrypted data is Goofy with roblox types so serialisation and deserialisation is needed
function serialiser.serialise(data)
	local t = typeof(data)

	if t == "Vector3" then
		return { __type = "Vector3", X = data.X, Y = data.Y, Z = data.Z }
	elseif t == "CFrame" then
		return { __type = "CFrame", C = {data:GetComponents()} }
	elseif t == "Color3" then
		return { __type = "Color3", R = data.R, G = data.G, B = data.B }
	elseif t == "EnumItem" then
		return { __type = "EnumItem", E = tostring(data.EnumType), N = data.Name }
	elseif t == "table" then
		local new_table = {}
		for k, v in data do
			new_table[k] = serialiser.serialise(v)
		end
		return new_table
	end

	return data
end

function serialiser.deserialise(data)
	if typeof(data) == "table" then
		if data.__type then
			if data.__type == "Vector3" then return Vector3.new(data.X, data.Y, data.Z) end
			if data.__type == "CFrame" then return CFrame.new(table.unpack(data.C)) end
			if data.__type == "Color3" then return Color3.new(data.R, data.G, data.B) end
			if data.__type == "EnumItem" then return Enum[data.E][data.N] end
		end

		local new_table = {}
		for k, v in data do
			new_table[k] = serialiser.deserialise(v)
		end
		return new_table
	end

	return data
end

return serialiser
