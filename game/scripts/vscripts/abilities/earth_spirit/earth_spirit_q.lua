require('abilities/earth_spirit/earth_spirit_remnant')

earth_spirit_q = class({})

function earth_spirit_q:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorPosition()

	local particle = ImmediateEffect("particles/units/heroes/hero_earth_spirit/espirit_magnetize_target.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControl(particle, 0, target)

	Timers:CreateTimer(1,
		function()
			local remnant = EarthSpiritRemnant()
			remnant:SetPos(target)
			remnant:CreateEffect()

			caster.hero:AddRemnant(remnant)
			Spells:AddDynamicEntity(remnant)

			EmitSoundOnLocationWithCaster(target, "Hero_EarthSpirit.StoneRemnant.Impact", caster)

			Timers:CreateTimer(0.1,
				function()
					particle = ImmediateEffect("particles/units/heroes/hero_elder_titan/elder_titan_echo_stomp.vpcf", PATTACH_CUSTOMORIGIN, caster)
					ParticleManager:SetParticleControl(particle, 0, target)

					GridNav:DestroyTreesAroundPoint(target, 256, true)
					Spells:MultipleHeroesDamage(caster.hero, 
						function (attacker, target)
							local distance = (target:GetPos() - point):Length2D()

							return target ~= attacker and target ~= remant and distance <= 256
						end
					)

					EmitSoundOnLocationWithCaster(target, "Arena.Earth.CastQ", caster)
				end
			)
		end
	)
end