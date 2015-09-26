pa_w = class({})
function pa_w:OnSpellStart()
	local caster = self:GetCaster()

	Timers:CreateTimer(0.3,
		function()
			local particle = "particles/econ/items/axe/axe_weapon_bloodchaser/axe_attack_blur_counterhelix_bloodchaser_b.vpcf"
			local id = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN_FOLLOW, caster)

			Spells:AreaDamage(caster, caster:GetAbsOrigin(), 256)
			GridNav:DestroyTreesAroundPoint(caster:GetAbsOrigin(), 256, true)

			Timers:CreateTimer(3, 
				function()
					ParticleManager:DestroyParticle(id, false)
					ParticleManager:ReleaseParticleIndex(id)
				end
			)
		end
	)
	
end

function pa_w:GetCastAnimation()
	return ACT_DOTA_CAST_ABILITY_1
end