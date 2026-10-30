const CollectionService = game:GetService("CollectionService")
const Players = game:GetService("Players")
const ReplicatedStorage = game:GetService("ReplicatedStorage")
const RunService = game:GetService("RunService")
const Workspace = game:GetService("Workspace")

const signal = require(ReplicatedStorage.Packages.signal)

export type entity = string | Player
-- Wally's entry module does not re-export Signal's types.
export type connection = {
	Disconnect: (self: connection) -> (),
	Destroy: (self: connection) -> (),
	Connected: boolean,
}

type event<T...> = {
	Fire: (self: event<T...>, T...) -> (),
	FireDeferred: (self: event<T...>, T...) -> (),
	Connect: (self: event<T...>, callback: (T...) -> ()) -> connection,
	Once: (self: event<T...>, callback: (T...) -> ()) -> connection,
	DisconnectAll: (self: event<T...>) -> (),
	GetConnections: (self: event<T...>) -> { connection },
	Destroy: (self: event<T...>) -> (),
	Wait: (self: event<T...>) -> T...,
}

const BOT_TAG = "bot"
const ID_ATTRIBUTE = "entity_id"
const TEAM_VALUE = "entity_team"

const added: event<entity> = signal.new()
const removed: event<entity> = signal.new()
const character_added: event<Model, entity> = signal.new()
const changed: event<> = signal.new()
const members: { [entity]: boolean? } = {}
const bots: { [string]: Model? } = {}
const bot_connections: { [Model]: { RBXScriptConnection }? } = {}
const bot_ids: { [Model]: string? } = {}
const player_connections: { [Player]: { RBXScriptConnection }? } = {}

local function get_character(entity: entity): Model?
	if type(entity) == "string" then
		return bots[entity]
	end
	return entity.Character
end

local function from_character(character: Model): entity?
	return Players:GetPlayerFromCharacter(character) or bot_ids[character]
end

local function get_all(): { entity }
	const entities: { entity } = {}
	for entity in members do
		table.insert(entities, entity)
	end
	return entities
end

local function get_name(entity: entity): string
	if type(entity) == "string" then
		const character = bots[entity]
		return if character then character.Name else entity
	end
	return entity.Name
end

local function get_team(entity: entity): Team?
	if type(entity) ~= "string" then
		return if entity.Neutral then nil else entity.Team
	end
	const character = bots[entity]
	const value = if character then character:FindFirstChild(TEAM_VALUE) else nil
	if value and value:IsA("ObjectValue") then
		const team = value.Value
		if team and team:IsA("Team") then
			return team
		end
	end
	return nil
end

local function set_team(entity: entity, team: Team?): ()
	assert(RunService:IsServer(), "Entity teams must be set on the server.")
	if type(entity) == "string" then
		const character = bots[entity]
		if character == nil then
			return
		end
		const existing = character:FindFirstChild(TEAM_VALUE)
		if existing then
			assert(existing:IsA("ObjectValue"), "Entity team must be an ObjectValue.")
			existing.Value = team
		else
			const value = Instance.new("ObjectValue")
			value.Name = TEAM_VALUE
			value.Value = team
			value.Parent = character
		end
	else
		if team then
			entity.Team = team
		end
		entity.Neutral = team == nil
	end
	changed:Fire()
end

local function on_bot_added(instance: Instance): ()
	if not instance:IsA("Model") or bot_ids[instance] ~= nil then
		return
	end
	const id = instance:GetAttribute(ID_ATTRIBUTE)
	if type(id) ~= "string" or id == "" or bots[id] ~= nil then
		return
	end
	bots[id] = instance
	bot_ids[instance] = id
	members[id] = true
	const connections: { RBXScriptConnection } = {}
	bot_connections[instance] = connections
	local function on_team_changed(): ()
		changed:Fire()
	end
	local function on_team_value_added(child: Instance): ()
		if child.Name == TEAM_VALUE and child:IsA("ObjectValue") then
			table.insert(connections, child.Changed:Connect(on_team_changed))
			on_team_changed()
		end
	end
	table.insert(connections, instance.ChildAdded:Connect(on_team_value_added))
	for _, child in instance:GetChildren() do
		on_team_value_added(child)
	end
	added:Fire(id)
	character_added:Fire(instance, id)
	changed:Fire()
end

local function on_bot_removed(instance: Instance): ()
	if not instance:IsA("Model") then
		return
	end
	const id = bot_ids[instance]
	if id == nil then
		return
	end
	const connections = bot_connections[instance]
	if connections then
		for _, connection in connections do
			connection:Disconnect()
		end
	end
	bot_connections[instance] = nil
	bots[id] = nil
	bot_ids[instance] = nil
	members[id] = nil
	removed:Fire(id)
	changed:Fire()
end

local function register_bot(id: string, character: Model): ()
	assert(RunService:IsServer(), "Bots must be registered on the server.")
	assert(id ~= "" and bots[id] == nil, "Bot IDs must be non-empty and unique.")
	assert(bot_ids[character] == nil, "Bot character is already registered.")
	assert(character:IsDescendantOf(Workspace), "Bot character must be in Workspace.")
	assert(Players:GetPlayerFromCharacter(character) == nil, "Bot character belongs to a player.")
	character:SetAttribute(ID_ATTRIBUTE, id)
	CollectionService:AddTag(character, BOT_TAG)
	on_bot_added(character)
end

local function unregister_bot(id: string): ()
	assert(RunService:IsServer(), "Bots must be removed on the server.")
	const character = bots[id]
	if character then
		on_bot_removed(character)
		CollectionService:RemoveTag(character, BOT_TAG)
	end
end

local function on_player_added(player: Player): ()
	if members[player] then
		return
	end
	members[player] = true
	local function on_character_added(character: Model): ()
		character_added:Fire(character, player)
	end
	local function on_team_changed(): ()
		changed:Fire()
	end
	player_connections[player] = {
		player.CharacterAdded:Connect(on_character_added),
		player:GetPropertyChangedSignal("Team"):Connect(on_team_changed),
		player:GetPropertyChangedSignal("Neutral"):Connect(on_team_changed),
	}
	added:Fire(player)
	if player.Character then
		on_character_added(player.Character)
	end
	changed:Fire()
end

local function on_player_removing(player: Player): ()
	const connections = player_connections[player]
	if connections then
		for _, connection in connections do
			connection:Disconnect()
		end
	end
	player_connections[player] = nil
	members[player] = nil
	removed:Fire(player)
	changed:Fire()
end

CollectionService:GetInstanceAddedSignal(BOT_TAG):Connect(on_bot_added)
CollectionService:GetInstanceRemovedSignal(BOT_TAG):Connect(on_bot_removed)
Players.PlayerAdded:Connect(on_player_added)
Players.PlayerRemoving:Connect(on_player_removing)

for _, player in Players:GetPlayers() do
	on_player_added(player)
end
for _, character in CollectionService:GetTagged(BOT_TAG) do
	on_bot_added(character)
end

return {
	added = added,
	changed = changed,
	character_added = character_added,
	from_character = from_character,
	get_all = get_all,
	get_character = get_character,
	get_name = get_name,
	get_team = get_team,
	register_bot = register_bot,
	removed = removed,
	set_team = set_team,
	unregister_bot = unregister_bot,
}
