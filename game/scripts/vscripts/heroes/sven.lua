Sven = class({}, {}, Hero)

function Sven:FilterCone(target, coneStart, coneEnd, coneWidth)
	local f = ((coneEnd - coneStart) * Vector(1, 1, 0)):Normalized()
	local offset = Vector(-f.y, f.x, 0) * coneWidth
	local coneLeft = coneEnd + offset
	local coneRight = coneEnd - offset

	--DebugDrawLine(coneStart, coneLeft, 0, 255, 0, false, 3)
	--DebugDrawLine(coneStart, coneRight, 0, 255, 0, false, 3)

	return IsLeft(coneLeft, coneStart, target) and not IsLeft(coneRight, coneStart, target)
end

function Sven:IsEnraged()
	return self:FindModifier("modifier_sven_r")
end

function Sven:ResetCooldowns()
	self.unit:FindAbilityByName("sven_q"):EndCooldown()
	self.unit:FindAbilityByName("sven_w"):EndCooldown()
	self.unit:FindAbilityByName("sven_e"):EndCooldown()
end

function Sven:Damage(source)
	if source == self or not self.unit:HasModifier("modifier_sven_e") then
		Hero.Damage(self, source)
	end
end