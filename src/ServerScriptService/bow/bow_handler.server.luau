const Players = game:GetService("Players")
const ReplicatedStorage = game:GetService("ReplicatedStorage")
const ServerScriptService = game:GetService("ServerScriptService")

const add_cooldown = require(ReplicatedStorage.shared.cooldown.add_cooldown)
const attack_entity = require(ServerScriptService.combat.attack_entity)
const BEHAVIOUR = require(ReplicatedStorage.shared.bow.bow_fastcast_behaviour)
const BOW_COOLDOWN_SERVER = require(script.Parent.BOW_COOLDOWN_SERVER)
const BOW_DAMAGE = require(script.Parent.BOW_DAMAGE)
const debug_print = require(ServerScriptService.util.debug_print)
const FastCast2 = require(ReplicatedStorage.Packages.FastCast2)
const is_on_cooldown = require(ReplicatedStorage.shared.cooldown.is_on_cooldown)
const registry = require(ReplicatedStorage.shared.entity.registry)

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

const MAX_ORIGIN_DISTANCE = 8
const shoot_bow = ReplicatedStorage.remotes.shoot_bow

const behavior = FastCast2.newBehavior()
behavior.MaxDistance = BEHAVIOUR.MAX_PROJ_DISTANCE
behavior.HighFidelityBehavior = BEHAVIOUR.HD_BEHAVIOUR
behavior.HighFidelitySegmentSize = BEHAVIOUR.HD_SEGMENT_SIZE
behavior.Acceleration = BEHAVIOUR.ACCELERATION
behavior.CosmeticBulletContainer = BEHAVIOUR.BULLET_CONTAINER
behavior.CosmeticBulletTemplate = BEHAVIOUR.BULLET_TEMPLATE

const caster = (FastCast2.new() :: unknown) :: caster_api
FastCast2.Init("BulkMoveTo")

local function on_hit(cast: active_cast, result: RaycastResult, velocity: Vector3, _bullet: Instance?): ()
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

local function on_cast_terminating(cast: active_cast): ()
	const bullet = cast.RayInfo.CosmeticBulletObject
	if bullet then
		bullet:Destroy()
	end
end

local function is_finite_vector(vector: Vector3): boolean
	return math.abs(vector.X) < math.huge and math.abs(vector.Y) < math.huge and math.abs(vector.Z) < math.huge
end

local function on_invoke(player: Player, origin: unknown, direction: unknown, dt: number): boolean
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
	if is_on_cooldown(player, "attack_bow") then
		return false
	end

	-- bow boosting
	const root = character:FindFirstChild("HumanoidRootPart")
	if root == nil or not root:IsA("BasePart") then
		return false
	end
	if dt < 0.3 and dt > 0.1 then
		attack_entity(player, player, math.clamp(BOW_DAMAGE / 2 * dt, 5, BOW_DAMAGE), {
			direction = root.CFrame.LookVector,
		})
	end

	const cast_params = RaycastParams.new()
	cast_params.FilterDescendantsInstances = { character, BEHAVIOUR.BULLET_CONTAINER }
	cast_params.FilterType = Enum.RaycastFilterType.Exclude
	cast_params.IgnoreWater = true

	const shot_behavior = table.clone(behavior)
	shot_behavior.RaycastParams = cast_params
	shot_behavior.UserData = {
		shooter = player,
		character = character,
		dt = dt,
	}

	add_cooldown(player, "attack_bow", BOW_COOLDOWN_SERVER)
	caster:RaycastFire(head.Position, direction.Unit, dt * BEHAVIOUR.SPEED, shot_behavior)
	return true
end

caster.Hit:Connect(on_hit)
caster.CastTerminating:Connect(on_cast_terminating)
shoot_bow.OnServerInvoke = on_invoke
