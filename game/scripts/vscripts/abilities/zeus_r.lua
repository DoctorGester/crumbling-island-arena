zeus_r = class({})
LinkLuaModifier("modifier_zeus_r", "abilities/modifier_zeus_r", LUA_MODIFIER_MOTION_NONE)

function zeus_r:OnSpellStart()
	local caster = self:GetCaster()
	local casterPos = caster:GetOrigin()
	local target = self:GetCursorPosition()
	local ability = self

	Timers:CreateTimer(0.8, 
		function()
			GridNav:DestroyTreesAroundPoint(target, 256, true)
			
			local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_zuus/zuus_lightning_bolt.vpcf", PATTACH_POINT, caster)
			ParticleManager:SetParticleControl(particle, 0, target)
			ParticleManager:SetParticleControl(particle, 1, target + Vector(0, 0, 2000))
			ParticleManager:ReleaseParticleIndex(particle)

			particle = ParticleManager:CreateParticle("particles/econ/items/zeus/lightning_weapon_fx/zuus_lightning_bolt_groundfx_crack.vpcf", PATTACH_POINT, caster)
			ParticleManager:SetParticleControl(particle, 3, target)
			ParticleManager:ReleaseParticleIndex(particle)

			Spells:AreaModifier(caster, ability, "modifier_zeus_r", { duration = 2.5 }, target, 256,
				function (caster, target)
					return caster ~= target
				end
			)

			Spells:AreaDamage(caster, caster:GetAbsOrigin(), 256)
		end
	)
end

function zeus_r:GetCastAnimation()
	return ACT_DOTA_CAST_ABILITY_4
end