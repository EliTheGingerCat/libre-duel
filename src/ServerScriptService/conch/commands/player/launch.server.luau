const ReplicatedStorage = game:GetService("ReplicatedStorage")
const ServerScriptService = game:GetService("ServerScriptService")

const apply_knockback = require(ReplicatedStorage.shared.combat.apply_knockback)
const conch = require(ReplicatedStorage.Packages.conch)
const format_count = require(ServerScriptService.util.format_count)
const get_living_humanoid = require(ServerScriptService.util.get_living_humanoid)
const LAUNCH_CONSTANTS = require(script.Parent.LAUNCH_CONSTANTS)

const function get_arguments()
	return conch.args.players("players", "The players to launch into the air"),
		conch.args.opt(
			conch.args.number("power", `Upwards speed in studs per second, {LAUNCH_CONSTANTS.DEFAULT_POWER} by default`)
		)
end

const function launch(players: { Player }, power: number?): string
	const speed = math.clamp(power or LAUNCH_CONSTANTS.DEFAULT_POWER, 0, LAUNCH_CONSTANTS.MAXIMUM_POWER)
	local launched = 0
	for _, player in players do
		const humanoid = get_living_humanoid(player)
		const root = if humanoid ~= nil then humanoid.RootPart else nil
		if root ~= nil then
			-- knockback strengths of 0 leave only the vertical speed
			apply_knockback(Vector3.new(0, speed, 0), root, 0, 0)
			launched += 1
		end
	end
	return `Launched {format_count(launched, "player")}`
end

conch.register("launch", {
	description = "Launches the given players into the air",
	permissions = { "administrator" },
	arguments = get_arguments,
	callback = launch,
})
