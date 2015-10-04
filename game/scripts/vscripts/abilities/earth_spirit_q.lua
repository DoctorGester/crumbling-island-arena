earth_spirit_q = class({})

function earth_spirit_q:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorPosition()

	local particle = ImmediateEffect("particles/units/heroes/hero_earth_spirit/espirit_magnetize_target.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControl(particle, 0, target)

	Timers:CreateTimer(1,
		function()
			local particle = ImmediateEffect("particles/units/heroes/hero_earth_spirit/espirit_stoneremnant.vpcf", PATTACH_CUSTOMORIGIN, caster)
			ParticleManager:SetParticleControl(particle, 0, target)
			ParticleManager:SetParticleControl(particle, 1, Vector(target.x, target.y, target.z + 2000))

			caster:EmitSound("Hero_EarthSpirit.StoneRemnant.Impact")

			Timers:CreateTimer(0.1,
				function()
					particle = ImmediateEffect("particles/units/heroes/hero_elder_titan/elder_titan_echo_stomp.vpcf", PATTACH_CUSTOMORIGIN, caster)
					ParticleManager:SetParticleControl(particle, 0, target)

					caster:EmitSound("Arena.Earth.CastQ")
				end
			)
		end
	)
end