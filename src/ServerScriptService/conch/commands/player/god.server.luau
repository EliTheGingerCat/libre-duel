const ReplicatedStorage = game:GetService("ReplicatedStorage")
const ServerScriptService = game:GetService("ServerScriptService")

const conch = require(ReplicatedStorage.Packages.conch)
const god_mode = require(ServerScriptService.combat.god_mode)

const function get_arguments()
	return conch.args.player("player", "The player to make invulnerable to attacks"),
		conch.args.opt(conch.args.boolean("enabled", "Toggles when left out"))
end

const function god(player: Player, enabled: boolean?): string
	const new_state = if enabled ~= nil then enabled else not god_mode.is_god(player)
	god_mode.set_god(player, new_state)
	return `God mode {if new_state then "enabled" else "disabled"} for {player.Name}`
end

conch.register("god", {
	description = "Makes a player take no damage or knockback from attacks",
	permissions = { "administrator" },
	arguments = get_arguments,
	callback = god,
})
