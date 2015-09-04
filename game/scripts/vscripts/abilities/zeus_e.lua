zeus_e = class({})

function zeus_e:OnSpellStart()
	local caster = self:GetCaster()
	local casterPos = caster:GetOrigin()
	local target = self:GetCursorPosition()
	local direction = (target - casterPos):Normalized()

	if direction:Length2D() == 0 then
		direction = caster:GetForwardVector()
	end
	
	direction.z = 0

	if (target - casterPos):Length2D() > 650 then
		target = casterPos + direction * 650
	end

	target.z = GetGroundHeight(target, caster)

	GridNav:DestroyTreesAroundPoint(target, 128, true)
	FindClearSpaceForUnit(caster, target, true)

	local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_zuus/zuus_arc_lightning.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControl(particle, 0, Vector(casterPos.x, casterPos.y, casterPos.z + 64))
	ParticleManager:SetParticleControl(particle, 1, Vector(target.x, target.y, target.z + 64))
	ParticleManager:ReleaseParticleIndex(particle)

	if caster.wall then
		local s = caster.wall.start
		local f = caster.wall.finish
		local intersect = SegmentsIntersect2(casterPos.x, casterPos.y, target.x, target.y, s.x, s.y, f.x, f.y)

		if intersect then
			Spells:LineDamage(caster, casterPos, target)
		end
	end
end

function zeus_e:GetCastAnimation()
	return ACT_DOTA_ATTACK
end