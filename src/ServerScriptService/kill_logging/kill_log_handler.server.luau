const ReplicatedStorage = game:GetService("ReplicatedStorage")
const ServerScriptService = game:GetService("ServerScriptService")

const kill_log_util = require(script.Parent.kill_log_util)
const registry = require(ReplicatedStorage.shared.entity.registry)
const send_notification = require(ServerScriptService.notification.send_notification)

const function on_entity_died(character, entity)
	const attacker = kill_log_util.get_entity_who_marked(entity)
	print(`{entity} died by {attacker}`)
	if not attacker or entity == attacker then
		send_notification("all", `{registry.get_name(entity)} killed themself`)
		return
	end
	send_notification("all", `{registry.get_name(entity)} has been killed by {registry.get_name(attacker)}`)
end

registry.died:Connect(on_entity_died)
