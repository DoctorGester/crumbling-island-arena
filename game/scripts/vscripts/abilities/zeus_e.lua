zeus_e = class({})

function zeus_e:CreateLightning(self, from, to)
	local particlePath = "particles/units/heroes/hero_razor/razor_storm_lightning_strike.vpcf"
	local particle = ParticleManager:CreateParticle(particlePath, PATTACH_CUSTOMORIGIN, self:GetCaster())
	ParticleManager:SetParticleControl(particle, 0, from)
	ParticleManager:SetParticleControl(particle, 1, to)

	Timers:CreateTimer(2, 
		function()
			ParticleManager:DestroyParticle(particle, false)
			ParticleManager:ReleaseParticleIndex(particle)
		end
	)
end

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

	if caster.wall then
		local s = caster.wall.start
		local f = caster.wall.finish
		local intersect = SegmentsIntersect2(casterPos.x, casterPos.y, target.x, target.y, s.x, s.y, f.x, f.y)

		if intersect then
			Spells:LineDamage(caster, casterPos, target,
				function(target)
					local pos = target.hero:GetAbsOrigin()
					self:CreateLightning(self, Vector(pos.x, pos.y, pos.z + 800), pos)
				end
			)
		end
	end

	self:CreateLightning(self, Vector(casterPos.x, casterPos.y, casterPos.z + 64), Vector(target.x, target.y, target.z + 64))
end

function zeus_e:GetCastAnimation()
	return ACT_DOTA_ATTACK
end