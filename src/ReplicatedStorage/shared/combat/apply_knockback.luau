local Debris = game:GetService("Debris")

local function apply_knockback(vector: Vector3, target: BasePart, strength_x: number?, strength_y: number?): ()
	local strength_x_result = strength_x or 1
	local strength_y_result = strength_y or 1

	local attachment = Instance.new("Attachment")

	local constant_velocity = Instance.new("LinearVelocity")
	constant_velocity.MaxForce = math.huge
	constant_velocity.Attachment0 = attachment
	constant_velocity.VectorVelocity =
		Vector3.new(vector.X * strength_x_result, vector.Y + strength_y_result, vector.Z * strength_x_result)
	constant_velocity.Parent = attachment

	-- Breter98: m~memowwy lyeaks awe bawwd~~~ OwO
	-- Eli: This would not just be a memory leak... the player would keep being knocked back forever.
	Debris:AddItem(attachment, 0.3)

	attachment.Parent = target
end

return apply_knockback
