const Players = game:GetService("Players")
const ReplicatedStorage = game:GetService("ReplicatedStorage")
const registry = require(ReplicatedStorage.shared.entity.registry)

const BLACKLISTED_STATES = {
    Enum.HumanoidStateType.FallingDown
}

const function on_state_changed(character, _entity, _old_state, new_state)
    const humanoid = character.Humanoid or nil
    if not humanoid then
        return
    end
    if not table.find(BLACKLISTED_STATES, new_state) then
        return
    end
    humanoid:ChangeState(Enum.HumanoidStateType.Running)
end

registry.state_changed:Connect(on_state_changed)
