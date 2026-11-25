local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

const IATA_AIRPORT_CODES = require(script.Parent.IATA_AIRPORT_CODES)
const LOCATION_DEFAULT = require(ReplicatedStorage.shared.ui.LOCATION_DEFAULT)
const zap_server_network = require(ServerScriptService.network.zap_server_network)

local location = LOCATION_DEFAULT

const function get_server_location(): IATA_AIRPORT_CODES.airport_info?
	const iata_code = game.ServerRegion :: string
	return IATA_AIRPORT_CODES[iata_code]
end

const location_maybe = get_server_location()
if location_maybe ~= nil then
	const location_formatted = `{location_maybe.city}, {location_maybe.country}`
	location = {
		status = "success",
		result = location_formatted,
	}
else
	location = {
		status = "fail",
	}
end

const function on_invoke(_player: Player): LOCATION_DEFAULT.location
	return location
end

zap_server_network.server_location.set_callback(on_invoke)
