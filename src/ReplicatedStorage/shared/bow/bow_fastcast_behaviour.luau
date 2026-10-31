local ReplicatedStorage = game:GetService("ReplicatedStorage")

local FastCast2 = require(ReplicatedStorage.Packages:WaitForChild("FastCast2"))

local BOW_FASTCAST_BEHAVIOUR = {
    SPEED = 150,

    MAX_PROJ_DISTANCE = 5000,
    HD_BEHAVIOUR = FastCast2.HighFidelityBehavior.Default,
    HD_SEGMENT_SIZE = 1,
    ACCELERATION = Vector3.new(-workspace.Gravity / 1.8, -workspace.Gravity / 1.8, -workspace.Gravity / 1.8),
    BULLET_CONTAINER = workspace:WaitForChild("Projectiles"),
    BULLET_TEMPLATE = ReplicatedStorage:WaitForChild("Projectile"),
}
return BOW_FASTCAST_BEHAVIOUR
