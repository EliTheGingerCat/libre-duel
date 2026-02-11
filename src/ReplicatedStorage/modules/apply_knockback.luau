local Debris = game:GetService("Debris")

-- `constant_strength` ensures that the distance between the attacker and the target does not affect knockback. In general, it should be `true`. An example of when it should be `false` is when the knockback is from an explosive.
local function apply_knockback(attacker: Part, target: Part, strength: number?, constant_strength: boolean?): ()
	local strength_result = strength or 1
	local constant_strength_enabled = constant_strength ~= false

	local direction = target.Position - attacker.Position

	if constant_strength_enabled then
		if direction.Magnitude > 0 then
			direction = direction.Unit * 25
		end
	end

	local attachment = Instance.new("Attachment")

	local constant_velocity = Instance.new("LinearVelocity")
	constant_velocity.MaxForce = 150000
	constant_velocity.Attachment0 = attachment
	constant_velocity.VectorVelocity = Vector3.new(direction.X, 15, direction.Z) * strength_result
	constant_velocity.Parent = attachment

	-- Breter98: m~memowwy lyeaks awe bawwd~~~ OwO
	-- Eli: This would not just be a memory leak... the player would keep being knocked back forever.
	Debris:AddItem(attachment, 0.2)
	
	attachment.Parent = target
end

return apply_knockback
