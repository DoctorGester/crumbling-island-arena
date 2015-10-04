zeus_q = class({})

function zeus_q:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorPosition()
	local direction = target - caster:GetOrigin()
	local ability = self

	if direction:Length2D() == 0 then
		direction = caster:GetForwardVector()
	end

	local projectileData = {}
	projectileData.owner = caster
	projectileData.from = caster:GetOrigin()
	projectileData.to = target
	projectileData.velocity = 1200
	projectileData.graphics = "particles/zeus_q/zeus_q.vpcf"
	projectileData.distance = 800
	projectileData.empowered = false
	projectileData.radius = 64
	projectileData.heroBehaviour =
		function(self, target)
			--"particles/units/heroes/hero_razor/razor_storm_lightning_strike.vpcf"
			Spells:ProjectileDamage(self, target)

			if self.empowered then
				ability:EndCooldown()
			end

			return true
		end

	projectileData.onMove = 
		function(self, prev, pos)
			if not self.empowered and caster.wall then
				local s = caster.wall.start
				local f = caster.wall.finish
				local intersect = SegmentsIntersect2(prev.x, prev.y, pos.x, pos.y, s.x, s.y, f.x, f.y)

				if intersect then
					self.velocity = self.velocity * 2.4
					self.distance = 3000
					self.empowered = true
				end
			end

			if (pos - projectileData.from):Length2D() >= self.distance then
				self:Destroy()
			end
		end

	Spells:CreateProjectile(projectileData)
end

function zeus_q:GetCastAnimation()
	return ACT_DOTA_CAST_ABILITY_1
end