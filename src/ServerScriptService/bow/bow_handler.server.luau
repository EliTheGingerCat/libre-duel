const Players = game:GetService("Players")
const ReplicatedStorage = game:GetService("ReplicatedStorage")
const ServerScriptService = game:GetService("ServerScriptService")

const BOW_BOOSTING_ENABLED = require(script.Parent.BOW_BOOSTING_ENABLED)
const add_cooldown = require(ReplicatedStorage.shared.cooldown.add_cooldown)
const attack_entity = require(ServerScriptService.combat.attack_entity)
const BEHAVIOUR = require(ReplicatedStorage.shared.bow.bow_fastcast_behaviour)
const BOW_COOLDOWN_SERVER = require(script.Parent.BOW_COOLDOWN_SERVER)
const BOW_DAMAGE = require(script.Parent.BOW_DAMAGE)
local bow_shot_event = require(script.Parent.bow_shot_event)
const debug_print = require(ServerScriptService.util.debug_print)
const FastCast2 = require(ReplicatedStorage.Packages.FastCast2)
const inventory_util = require(ServerScriptService.inventory.inventory_util)
const is_on_cooldown = require(ReplicatedStorage.shared.cooldown.is_on_cooldown)
const registry = require(ReplicatedStorage.shared.entity.registry)
local inventory_logic = require(ReplicatedStorage.shared.inventory.inventory_logic)

type active_cast = {
	UserData: {
		shooter: Player,
		character: Model,
		dt: number,
	},
	RayInfo: {
		CosmeticBulletObject: Instance?,
	},
}

type hit_handler = (active_cast, RaycastResult, Vector3, Instance?) -> ()
type caster_api = {
	Hit: {
		Connect: (self: unknown, callback: hit_handler) -> unknown,
	},
	CastTerminating: {
		Connect: (self: unknown, callback: (active_cast) -> ()) -> unknown,
	},
	RaycastFire: (self: unknown, Vector3, Vector3, number, typeof(FastCast2.newBehavior())) -> active_cast,
}

const MAX_ORIGIN_DISTANCE = 32
const shoot_bow = ReplicatedStorage.remotes.shoot_bow

const behaviour = FastCast2.newBehavior()
behaviour.MaxDistance = BEHAVIOUR.MAX_PROJ_DISTANCE
behaviour.HighFidelityBehavior = BEHAVIOUR.HD_BEHAVIOUR
behaviour.HighFidelitySegmentSize = BEHAVIOUR.HD_SEGMENT_SIZE
behaviour.Acceleration = BEHAVIOUR.ACCELERATION
behaviour.CosmeticBulletContainer = BEHAVIOUR.BULLET_CONTAINER
behaviour.CosmeticBulletTemplate = BEHAVIOUR.BULLET_TEMPLATE

const caster = (FastCast2.new() :: unknown) :: caster_api
FastCast2.Init("BulkMoveTo")

const function on_hit(cast: active_cast, result: RaycastResult, velocity: Vector3, _bullet: Instance?): ()
	const attacker = cast.UserData.shooter
	if attacker.Parent ~= Players or attacker.Character ~= cast.UserData.character then
		return
	end

	const target_character = result.Instance:FindFirstAncestorOfClass("Model")
	if target_character == nil then
		return
	end

	const target = registry.from_character(target_character)
	if target == nil or target == attacker then
		return
	end

	const magnitude = velocity.Magnitude
	if magnitude <= 0 or magnitude >= math.huge then
		return
	end

	const dt = cast.UserData.dt

	attack_entity(attacker, target, math.clamp(BOW_DAMAGE / 2 * dt, 5, BOW_DAMAGE), {
		direction = velocity.Unit,
	})
end

const function on_cast_terminating(cast: active_cast): ()
	const bullet = cast.RayInfo.CosmeticBulletObject
	if bullet then
		bullet:Destroy()
	end
end

const function is_finite_vector(vector: Vector3): boolean
	return math.abs(vector.X) < math.huge and math.abs(vector.Y) < math.huge and math.abs(vector.Z) < math.huge
end

const function on_invoke(player: Player, origin: unknown, direction: unknown, dt: number): boolean
	if typeof(origin) ~= "Vector3" or typeof(direction) ~= "Vector3" then
		return false
	end

	if not is_finite_vector(origin) or not is_finite_vector(direction) then
		return false
	end

	const magnitude = direction.Magnitude
	if magnitude <= 0 or magnitude >= math.huge then
		return false
	end

	const character = player.Character
	if player.Parent ~= Players or character == nil or not character:IsDescendantOf(workspace) then
		return false
	end

	const humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid == nil or humanoid.Health <= 0 then
		return false
	end

	const head = character:FindFirstChild("Head")
	if head == nil or not head:IsA("BasePart") then
		return false
	end

	if (origin - head.Position).Magnitude > MAX_ORIGIN_DISTANCE then
		debug_print("Bow origin is too far from the shooter.")
		return false
	end

	if not inventory_util.has_behaviour(player, "bow") then
		return false
	end

	const inventory = inventory_util.get_inventory(player)
	if inventory and not inventory_logic.find_item(inventory, "arrow") then
		return false
	end

	if is_on_cooldown(player, "attack_bow") then
		return false
	end

	const root = character:FindFirstChild("HumanoidRootPart")
	if root == nil or not root:IsA("BasePart") then
		return false
	end

	-- bow boosting
	if dt < 0.3 and dt > 0.1 and BOW_BOOSTING_ENABLED then
		attack_entity(player, player, math.clamp(BOW_DAMAGE / 2 * dt, 5, BOW_DAMAGE), {
			direction = root.CFrame.LookVector,
		})
		add_cooldown(player, "attack_bow", BOW_COOLDOWN_SERVER)
		bow_shot_event:Fire(player)
		return inventory_util.consume_item(player, "arrow")
	end

	const cast_params = RaycastParams.new()
	cast_params.FilterDescendantsInstances = { character, BEHAVIOUR.BULLET_CONTAINER }
	cast_params.FilterType = Enum.RaycastFilterType.Exclude
	cast_params.IgnoreWater = true

	const shot_behaviour = table.clone(behaviour)
	shot_behaviour.RaycastParams = cast_params
	shot_behaviour.UserData = {
		shooter = player,
		character = character,
		dt = dt,
	}

	add_cooldown(player, "attack_bow", BOW_COOLDOWN_SERVER)
	const cast = caster:RaycastFire(head.Position, direction.Unit, dt * BEHAVIOUR.SPEED, shot_behaviour)
	const bullet = cast.RayInfo.CosmeticBulletObject
	if bullet then
		-- lets clients skip flyby sounds for their own arrows
		bullet:SetAttribute("shooter_user_id", player.UserId)
	end
	bow_shot_event:Fire(player)
	inventory_util.consume_item(player, "arrow")
	return true
end

caster.Hit:Connect(on_hit)
caster.CastTerminating:Connect(on_cast_terminating)
shoot_bow.OnServerInvoke = on_invoke
