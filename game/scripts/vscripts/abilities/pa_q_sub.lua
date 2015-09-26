pa_q_sub = class({})

function pa_q_sub:OnSpellStart()
	local caster = self:GetCaster()
	local positionMethod = 
		function(self)
			local dif = (self.owner:GetAbsOrigin() - self.position)
			dif = Vector(dif.x, dif.y, 0):Normalized() * 1200

			return self.position + dif * Misc:GetPASpeedMultiplier(self) / 30
		end

	if caster.paQProjectile then 
		caster.paQProjectile:SetPositionMethod(positionMethod)
	end

	if caster.paQProp then
		local projectileData = {}
		projectileData.owner = caster
		projectileData.from = caster.paQProp:GetOrigin()
		projectileData.graphics = ""
		projectileData.radius = 64
		projectileData.positionMethod =
			function(self)
				local angles = self.dummy:GetAngles()
				local result = RotateOrientation(angles, QAngle(0, 5, 0))
				self.dummy:SetAngles(result.x, result.y, result.z)
				self.curAngle = self.curAngle + 5

				return positionMethod(self)
			end

		Misc:SetUpPAProjectile(projectileData)

		local projectile = Spells:CreateProjectile(projectileData)
		projectile.gracePeriod = {}
		projectile.gracePeriod[projectile.owner] = 30
		projectile:Remove()
		projectile.dummy = caster.paQProp
		projectile.curAngle = 5

		caster.paQProp = nil
	end

	self:SetActivated(false)
end

function pa_q_sub:GetCastAnimation()
	return ACT_DOTA_CAST_ABILITY_1
end