type server_types = "vip" | "reserved" | "standard"

const function get_server_type(): server_types
	if game.PrivateServerId ~= "" then
		if game.PrivateServerOwnerId ~= 0 then
			return "vip"
		else
			return "reserved"
		end
	else
		return "standard"
	end
end

return get_server_type
