storm_spirit_q = class({})

function storm_spirit_q:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorPosition()
	local direction = target - caster:GetOrigin()

	if direction:Length2D() == 0 then
		direction = caster:GetForwardVector()
	end

	local projectileData = {}
	projectileData.owner = caster
	projectileData.from = caster:GetOrigin()
	projectileData.to = target
	projectileData.velocity = 800
	projectileData.graphics = "particles/storm_q/storm_q2.vpcf"
	projectileData.heroBehaviour = BEHAVIOUR_DEAL_DAMAGE_AND_PASS
	projectileData.endPoint = target
	projectileData.onTargetReached = 
		function (projectile)
			Misc:CreateStormRemnant(projectile.owner, projectile.position, direction:Normalized())
			projectile:Destroy()
		end
	projectileData.onWallDestroy = projectileData.onTargetReached

	Spells:CreateProjectile(projectileData)
	caster:EmitSound("Arena.Storm.CastQ")
end

function storm_spirit_q:GetCastAnimation()
	return ACT_DOTA_CAST_ABILITY_2
end