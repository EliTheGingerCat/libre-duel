-- accepts "123", "rbxassetid://123" or a create.roblox.com / library link, returns "rbxassetid://123"
const function parse_image_id(text: string): string?
	const asset_id = string.match(text, "^%s*(%d+)%s*$")
		or string.match(text, "rbxassetid://(%d+)")
		or string.match(text, "/(%d+)/?")
	return if asset_id then `rbxassetid://{asset_id}` else nil
end

return parse_image_id
