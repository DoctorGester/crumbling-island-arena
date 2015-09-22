pa_q = class({})

function pa_q:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorPosition()
	local direction = target - caster:GetOrigin()
	local ability = self

	local maxSpeed = 800

	if direction:Length2D() == 0 then
		direction = caster:GetForwardVector()
	end

	local projectileData = {}
	projectileData.owner = caster
	projectileData.from = caster:GetOrigin()
	projectileData.to = target
	projectileData.graphics = "particles/pa_q/pa_q.vpcf"
	projectileData.radius = 48
	projectileData.heroCondition =
		function(self, target, prev, pos)
			if self.gracePeriodOwner > 0 then
				return false
			end

			return SegmentCircleIntersection(prev, pos, target.hero:GetAbsOrigin(), self.radius)
		end

	projectileData.heroBehaviour =
		function(self, target)
			if self.owner == target then
				
			else
				Spells:ProjectileDamage(self, target)
			end

			return true
		end

	projectileData.positionMethod = 
		function(self)
			local dif = (self.owner:GetAbsOrigin() - self.position)
			dif = Vector(dif.x, dif.y, 0):Normalized()

			self.velocity = self.velocity + dif * 20
			return self.position + self.velocity / 30
		end

	projectileData.onMove = 
		function(self)
			self.gracePeriodOwner = self.gracePeriodOwner - 1
		end

	local projectile = Spells:CreateProjectile(projectileData)
	projectile.direction = Vector(direction.x, direction.y, 0):Normalized()
	projectile.velocity = projectile.direction * maxSpeed
	projectile.gracePeriodOwner = 30
end

function pa_q:GetCastAnimation()
	return ACT_DOTA_CAST_ABILITY_1
end