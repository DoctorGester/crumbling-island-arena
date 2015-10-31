cm_e = class({})

function cm_e:OnSpellStart()
	local hero = self:GetCaster().hero
	local target = self:GetCursorPosition()
	local direction = target - hero:GetPos()
	local ability = self

	if direction:Length2D() == 0 then
		direction = hero:GetFacing()
	end

	local projectileData = {}
	projectileData.owner = hero
	projectileData.from = hero:GetPos()
	projectileData.to = target
	projectileData.velocity = 700
	projectileData.graphics = "particles/cm/cm_e.vpcf"
	projectileData.distance = 1100
	projectileData.empowered = false
	projectileData.radius = 64
	projectileData.heroBehaviour =
		function(self, target)
			self.damagedGroup = self.damagedGroup or {}

			if not self.damagedGroup[target] then
				if hero:IsFrozen(target) then
					Spells:ProjectileDamage(self, target)
				end

				target:EmitSound("Arena.CM.HitE")
				hero:Freeze(target, ability)
				self.damagedGroup[target] = true
			end

			return false
		end

	projectileData.onTargetReached = 
		function (projectile)
			hero:StopSound("Arena.CM.LoopE")
			hero:SwapAbilities("cm_e_sub", "cm_e")
			hero:SetIcePath(nil)
			projectile:Destroy()
		end

	projectileData.onProjectileCollision = projectileData.onTargetReached
	projectileData.onWallDestroy = projectileData.onTargetReached

	hero:SetIcePath(Spells:CreateProjectile(projectileData))
	hero:EmitSound("Arena.CM.CastE")
	hero:EmitSound("Arena.CM.LoopE")
	hero:SwapAbilities("cm_e", "cm_e_sub")
end

function cm_e:GetCastAnimation()
	return ACT_DOTA_CAST_ABILITY_2
end