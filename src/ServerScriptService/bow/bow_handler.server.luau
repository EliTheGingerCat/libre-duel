local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local FastCast2 = require(ReplicatedStorage.Packages:WaitForChild("FastCast2"))
local registry = require(ReplicatedStorage.shared.entity.registry)
local BEHAVIOUR = require(ReplicatedStorage.shared.bow.bow_fastcast_behaviour)

local shoot_bow = ReplicatedStorage.remotes.shoot_bow

type hit_handler = (unknown, RaycastResult, Vector3, Instance?) -> ()
type caster_api = {
	Hit: {
		Connect: (self: unknown, callback: hit_handler) -> unknown,
	},
	RaycastFire: (self: unknown, Vector3, Vector3, number, typeof(FastCast2.newBehavior())) -> unknown,
}

local CastParams = RaycastParams.new()
CastParams.FilterType = Enum.RaycastFilterType.Exclude
CastParams.IgnoreWater = true

local behavior = FastCast2.newBehavior()
behavior.MaxDistance = BEHAVIOUR.MAX_PROJ_DISTANCE
behavior.RaycastParams = CastParams
behavior.HighFidelityBehavior = BEHAVIOUR.HD_BEHAVIOUR
behavior.HighFidelitySegmentSize = BEHAVIOUR.HD_SEGMENT_SIZE
behavior.Acceleration = BEHAVIOUR.ACCELERATION
behavior.CosmeticBulletContainer = BEHAVIOUR.BULLET_CONTAINER
behavior.CosmeticBulletTemplate = BEHAVIOUR.BULLET_TEMPLATE

const caster = (FastCast2.new() :: unknown) :: caster_api
FastCast2.Init("BulkMoveTo")

local function on_hit(_cast: unknown, result: RaycastResult, _velocity: Vector3, _bullet: Instance?): ()
	const character = result.Instance:FindFirstAncestorOfClass("Model")
	if character == nil then
		return
	end
	const target = registry.from_character(character)
	if target == nil then
		return
	end
	print(`Hit: {registry.get_name(target)}`)
end
caster.Hit:Connect(on_hit)

shoot_bow.OnServerInvoke = function(player, origin, direction)
    local hi = caster:RaycastFire(origin, direction, BEHAVIOUR.SPEED, behavior)
    print(player, origin, direction, hi)
end
