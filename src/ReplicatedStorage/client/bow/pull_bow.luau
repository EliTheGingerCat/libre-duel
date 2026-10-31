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

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local Head = character:WaitForChild("Head")
local Mouse = player:GetMouse()

local CastParams = RaycastParams.new()
CastParams.FilterDescendantsInstances = { character }
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

local function pull_bow(): ()
	local origin = Head.Position
	local direction = (Mouse.Hit.Position - origin).Unit
	caster:RaycastFire(origin, direction, BEHAVIOUR.SPEED, behavior)
	shoot_bow:InvokeServer(origin, direction)
end

return pull_bow
