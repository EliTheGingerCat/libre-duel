const ReplicatedStorage = game:GetService("ReplicatedStorage")
const ServerScriptService = game:GetService("ServerScriptService")

const create_held_part = require(script.Parent.create_held_part)
const inventory_util = require(ServerScriptService.inventory.inventory_util)
const registry = require(ReplicatedStorage.shared.entity.registry)
const tool_types = require(ReplicatedStorage.shared.tools.tool_types)
const THIRD_PERSON_TOOL_CONSTANTS = require(script.Parent.THIRD_PERSON_TOOL_CONSTANTS)

type held_tool = {
    tool: tool_types.tool,
    hand: BasePart,
    part: BasePart,
}

const held_tools: { [registry.entity]: held_tool } = {}
const hand_connections: { [registry.entity]: RBXScriptConnection } = {}

local function is_hand(instance: Instance): boolean
    return instance.Name == "RightHand" or instance.Name == "Right Arm"
end

local function find_hand(character: Model): BasePart?
    for _, child in character:GetChildren() do
        if is_hand(child) and child:IsA("BasePart") then
            return child
        end
    end
    return nil
end

local function remove_held_tool(entity: registry.entity): ()
    const held = held_tools[entity]
    if held ~= nil then
        held.part:Destroy()
        held_tools[entity] = nil
    end
end

local function attach_to_hand(part: BasePart, hand: BasePart, character: Model): ()
    const weld = Instance.new("Weld")
    weld.Part0 = hand
    weld.Part1 = part
    weld.C0 = CFrame.new(0, -hand.Size.Y / 2, 0) * THIRD_PERSON_TOOL_CONSTANTS.grip
    weld.Parent = part
    part.Parent = character
end

local function update_held_tool(entity: registry.entity): ()
    const character = registry.get_character(entity)
    const hand = if character ~= nil then find_hand(character) else nil
    const tool = inventory_util.get_selected_tool(entity)

    const held = held_tools[entity]
    if held ~= nil and held.tool == tool and held.hand == hand then
        return
    end
    remove_held_tool(entity)

    if character == nil or hand == nil or tool == nil then
        return
    end
    const part = create_held_part(tool)
    if part ~= nil then
        attach_to_hand(part, hand, character)
        held_tools[entity] = { tool = tool, hand = hand, part = part }
    end
end

local function stop_watching_hand(entity: registry.entity): ()
    const connection = hand_connections[entity]
    if connection then
        connection:Disconnect()
        hand_connections[entity] = nil
    end
end

local function on_character_added(character: Model, entity: registry.entity): ()
    -- the hand may not exist yet, and loading the avatar can replace it
    local function on_child_added(child: Instance): ()
        if is_hand(child) then
            -- deferred so that the old hand is gone by then if it was replaced this frame
            task.defer(update_held_tool, entity)
        end
    end

    stop_watching_hand(entity)
    hand_connections[entity] = character.ChildAdded:Connect(on_child_added)
    update_held_tool(entity)
end

local function on_entity_removed(entity: registry.entity): ()
    stop_watching_hand(entity)
    -- unregistering a bot keeps its character around
    remove_held_tool(entity)
end

inventory_util.changed:Connect(update_held_tool)
registry.character_added:Connect(on_character_added)
registry.removed:Connect(on_entity_removed)

for _, entity in registry.get_all() do
    const character = registry.get_character(entity)
    if character ~= nil then
        on_character_added(character, entity)
    end
end
