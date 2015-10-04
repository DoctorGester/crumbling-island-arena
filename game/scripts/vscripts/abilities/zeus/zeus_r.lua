zeus_r = class({})
LinkLuaModifier("modifier_zeus_r", "abilities/zeus/modifier_zeus_r", LUA_MODIFIER_MOTION_NONE)

function zeus_r:OnSpellStart()
	local caster = self:GetCaster()
	local casterPos = caster:GetOrigin()
	local target = self:GetCursorPosition()
	local ability = self

	caster:EmitSound("Hero_Zuus.GodsWrath.PreCast")

	Timers:CreateTimer(1.6, 
		function()
			GridNav:DestroyTreesAroundPoint(target, 256, true)
			
			local particle = ImmediateEffect("particles/units/heroes/hero_zuus/zuus_lightning_bolt.vpcf", PATTACH_POINT, caster)
			ParticleManager:SetParticleControl(particle, 0, target)
			ParticleManager:SetParticleControl(particle, 1, target + Vector(0, 0, 2000))

			particle = ImmediateEffect("particles/econ/items/zeus/lightning_weapon_fx/zuus_lightning_bolt_groundfx_crack.vpcf", PATTACH_POINT, caster)
			ParticleManager:SetParticleControl(particle, 3, target)

			Spells:AreaModifier(caster, ability, "modifier_zeus_r", { duration = 4.5 }, target, 256,
				function (caster, target)
					return caster ~= target
				end
			)

			Spells:AreaDamage(caster, caster:GetAbsOrigin(), 256,
				function (player)
					local to = player.hero:GetPos()
					local particle = ImmediateEffect("particles/units/heroes/hero_zuus/zuus_arc_lightning.vpcf", PATTACH_CUSTOMORIGIN, caster)
					ParticleManager:SetParticleControl(particle, 0, Vector(target.x, target.y, target.z + 64))
					ParticleManager:SetParticleControl(particle, 1, to)
				end
			)

			EmitSoundOnLocationWithCaster(target, "Hero_Zuus.GodsWrath.Target", caster)
		end
	)
end

function zeus_r:GetCastAnimation()
	return ACT_DOTA_CAST_ABILITY_4
end