storm_spirit_q = class({})
LinkLuaModifier("modifier_storm_spirit_remnant", "abilities/storm_spirit/modifier_storm_spirit_remnant", LUA_MODIFIER_MOTION_NONE)

function storm_spirit_q:OnSpellStart()
	local hero = self:GetCaster().hero
	local target = self:GetCursorPosition()
	local direction = target - hero:GetPos()

	if direction:Length2D() == 0 then
		direction = hero:GetFacing()
	end

	local projectileData = {}
	projectileData.owner = hero
	projectileData.from = hero:GetPos()
	projectileData.to = target
	projectileData.velocity = 800
	projectileData.graphics = "particles/storm_q/storm_q2.vpcf"
	projectileData.heroBehaviour = BEHAVIOUR_DEAL_DAMAGE_AND_PASS
	projectileData.endPoint = target
	projectileData.onTargetReached = 
		function (projectile)
			hero:CreateRemnant(projectile.position, direction:Normalized())
			projectile:Destroy()
		end
	projectileData.onWallDestroy = projectileData.onTargetReached

	Spells:CreateProjectile(projectileData)
	hero:EmitSound("Arena.Storm.CastQ")
end

function storm_spirit_q:GetCastAnimation()
	return ACT_DOTA_CAST_ABILITY_2
end