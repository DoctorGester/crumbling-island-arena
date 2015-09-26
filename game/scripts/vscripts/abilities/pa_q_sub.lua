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
		local ticksLeft = 10

		Timers:CreateTimer(
			function()
				local abs = caster.paQProp:GetAbsOrigin()
				abs.z = abs.z + 15
				caster.paQProp:SetAbsOrigin(abs)
				ticksLeft = ticksLeft - 1

				local angles = caster.paQProp:GetAngles()
				local result = RotateOrientation(angles, QAngle(0, 9, 0))
				caster.paQProp:SetAngles(result.x, result.y, result.z)

				if ticksLeft == 0 then
					local projectileData = {}
					projectileData.owner = caster
					projectileData.from = caster.paQProp:GetOrigin()
					projectileData.graphics = "particles/pa_q/pa_q.vpcf"
					projectileData.radius = 64
					projectileData.positionMethod =
						function(self)
							local angles = self.dummy:GetAngles()
							local result = RotateOrientation(angles, QAngle(65, 0, 0))
							self.dummy:SetAngles(result.x, result.y, result.z)

							return positionMethod(self)
						end

					Misc:SetUpPAProjectile(projectileData)

					local projectile = Spells:CreateProjectile(projectileData)
					projectile.gracePeriod = {}
					projectile.gracePeriod[projectile.owner] = 0
					projectile:Remove()
					projectile.dummy = caster.paQProp
					projectile.curAngle = 5

					caster.paQProp = nil

					return false
				end

				return 0.01
			end
		)
	end

	self:SetActivated(false)
end

function pa_q_sub:GetCastAnimation()
	return ACT_DOTA_CAST_ABILITY_1
end