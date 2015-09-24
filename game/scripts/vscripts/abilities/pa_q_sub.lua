pa_q_sub = class({})

function pa_q_sub:OnSpellStart()
	local caster = self:GetCaster()

	caster.pa_q_projectile:SetPositionMethod(
		function(self)
			local dif = (self.owner:GetAbsOrigin() - self.position)
			dif = Vector(dif.x, dif.y, 0):Normalized() * 1200

			return self.position + dif * Misc:GetPASpeedMultiplier(self) / 30
		end
	)
end

function pa_q_sub:GetCastAnimation()
	return ACT_DOTA_CAST_ABILITY_1
end