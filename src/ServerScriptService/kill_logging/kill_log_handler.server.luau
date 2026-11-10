const ReplicatedStorage = game:GetService("ReplicatedStorage")
const registry = require(ReplicatedStorage.shared.entity.registry)

const kill_log_util = require(script.Parent.kill_log_util)

const function on_entity_died(character, entity)
    const attacker = kill_log_util.get_entity_who_marked(entity)
    print(`{entity} died by {attacker}`)
    if not attacker then
        return
    end
    ReplicatedStorage.remotes.send_notification:FireAllClients(`{registry.get_name(entity)} has been killed by {registry.get_name(attacker)}`)
end

registry.died:Connect(on_entity_died)
