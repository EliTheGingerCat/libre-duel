local ReplicatedStorage = game:GetService("ReplicatedStorage")

local FastCast2 = require(ReplicatedStorage.Packages.FastCast2)

local BOW_FASTCAST_BEHAVIOUR = {
    SPEED = 150,

    MAX_PROJ_DISTANCE = 5000,
    HD_BEHAVIOUR = FastCast2.HighFidelityBehavior.Default,
    HD_SEGMENT_SIZE = 1,
    ACCELERATION = Vector3.new(0, -workspace.Gravity / 1.8, 0),
    BULLET_CONTAINER = workspace.runtime_instances.projectiles,
    BULLET_TEMPLATE = ReplicatedStorage.shared.bow.arrow,
}
return BOW_FASTCAST_BEHAVIOUR
