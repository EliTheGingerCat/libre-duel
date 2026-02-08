local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ipinfo = require(script.Parent.modules.IPinfo)
local location_default = require(ReplicatedStorage.modules.location_default)

local location = location_default

local function get_server_location_legacy(): string?
	local data = ipinfo.get_legacy()

	local country = data.country
	if country == nil then
		print("[IPinfo] Country is nil.")
		return nil
	end

	local city = data.city
	if city == nil then
		print("[IPinfo] City is nil.")
		return nil
	end

	return `{city}, {country}`
end

local function get_server_location_Lite(): string?
	local data = ipinfo.get_Lite()

	local country = data.country
	if country == nil then
		print("[IPinfo] Country is nil.")
		return nil
	end

	return country
end

local function get_token(): string?
	local token_module = script.Parent.modules:FindFirstChild("IPinfo_token") :: ModuleScript?
	if token_module ~= nil then
		return require(token_module) :: string
	end

	return nil
end

local function get_server_location(): string?
	local token = get_token()
	if token ~= nil then
		ipinfo.set_token(token)
	else
		-- Legacy is better anyway since it provides city.
		print("[IPinfo] Non-fatal warning: No token. Only legacy API can be used.")
	end

	local location = get_server_location_legacy()
	if location ~= nil then
		return location
	end
	
	if token ~= nil then
		location = get_server_location_Lite()
		if location ~= nil then
			return location
		end
	end

	return nil
end

local location_maybe = get_server_location()
if location_maybe ~= nil then
	location = {
		status = "success",
		result = location_maybe,
	}
else
	location = {
		status = "fail",
	}
end

local function on_invoke(): location_default.location
	return location
end

ReplicatedStorage.remotes.server_location.OnServerInvoke = on_invoke
