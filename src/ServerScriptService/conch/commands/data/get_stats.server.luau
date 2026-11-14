const ReplicatedStorage = game:GetService("ReplicatedStorage")
const ServerScriptService = game:GetService("ServerScriptService")

const conch = require(ReplicatedStorage.Packages.conch)
const format_player_data = require(ServerScriptService.player_data.format_player_data)
const read_player_data = require(ServerScriptService.player_data.read_player_data)

const function get_arguments()
	return conch.args.userid("user", "The username or user id to look up, they can be offline")
end

-- every returned value becomes its own line in the console
const function get_stats(user_id: number): ...string
	const data = read_player_data(user_id)
	if data == nil then
		return `Could not read the data of {user_id}`
	end
	return `Stats of {user_id}`, table.unpack(format_player_data(data))
end

conch.register("get_stats", {
	description = "Shows the saved stats of a player",
	permissions = { "administrator" },
	arguments = get_arguments,
	callback = get_stats,
})
