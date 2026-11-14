const ReplicatedStorage = game:GetService("ReplicatedStorage")
const ServerScriptService = game:GetService("ServerScriptService")

const conch = require(ReplicatedStorage.Packages.conch)
const format_count = require(ServerScriptService.util.format_count)
const get_living_humanoid = require(ServerScriptService.util.get_living_humanoid)

const function get_arguments()
	return conch.args.players("players", "The players to heal")
end

const function heal(players: { Player }): string
	local healed = 0
	for _, player in players do
		const humanoid = get_living_humanoid(player)
		if humanoid ~= nil then
			humanoid.Health = humanoid.MaxHealth
			healed += 1
		end
	end
	return `Healed {format_count(healed, "player")}`
end

conch.register("heal", {
	description = "Restores the given players to full health",
	permissions = { "administrator" },
	arguments = get_arguments,
	callback = heal,
})
