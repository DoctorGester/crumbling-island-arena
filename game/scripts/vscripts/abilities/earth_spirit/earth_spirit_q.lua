require('abilities/earth_spirit/earth_spirit_remnant')

earth_spirit_q = class({})

function earth_spirit_q:OnSpellStart()
	local caster = self:GetCaster()
	local cursor = self:GetCursorPosition()

	local particle = ImmediateEffect("particles/units/heroes/hero_earth_spirit/espirit_magnetize_target.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControl(particle, 0, cursor)

	Timers:CreateTimer(1,
		function()
			local remnant = EarthSpiritRemnant(caster.hero)
			remnant:SetPos(cursor)
			remnant:CreateEffect()

			caster.hero:AddRemnant(remnant)
			Spells:AddDynamicEntity(remnant)

			EmitSoundOnLocationWithCaster(cursor, "Hero_EarthSpirit.StoneRemnant.Impact", caster)

			Timers:CreateTimer(0.1,
				function()
					particle = ImmediateEffect("particles/units/heroes/hero_elder_titan/elder_titan_echo_stomp.vpcf", PATTACH_CUSTOMORIGIN, caster)
					ParticleManager:SetParticleControl(particle, 0, cursor)

					GridNav:DestroyTreesAroundPoint(cursor, 256, true)
					Spells:MultipleHeroesDamage(caster.hero, 
						function (source, target)
							local distance = (target:GetPos() - cursor):Length2D()

							if target ~= source and target ~= remnant and distance <= 256 then
								if target:__instanceof__(EarthSpiritRemnant) then
									target:Destroy()
									return false
								end

								return true
							end
						end
					)

					EmitSoundOnLocationWithCaster(cursor, "Arena.Earth.CastQ", caster)
				end
			)
		end
	)
end