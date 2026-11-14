const ReplicatedStorage = game:GetService("ReplicatedStorage")
const ServerScriptService = game:GetService("ServerScriptService")

const conch = require(ReplicatedStorage.Packages.conch)
const format_count = require(ServerScriptService.util.format_count)
const get_living_humanoid = require(ServerScriptService.util.get_living_humanoid)

const function get_arguments()
	return conch.args.players("players", "The players to kill")
end

-- sets health directly, so it also goes through god mode
const function kill(players: { Player }): string
	local killed = 0
	for _, player in players do
		const humanoid = get_living_humanoid(player)
		if humanoid ~= nil then
			humanoid.Health = 0
			killed += 1
		end
	end
	return `Killed {format_count(killed, "player")}`
end

conch.register("kill", {
	description = "Kills the given players",
	permissions = { "administrator" },
	arguments = get_arguments,
	callback = kill,
})
