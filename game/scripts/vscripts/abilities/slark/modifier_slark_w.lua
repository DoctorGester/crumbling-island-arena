modifier_slark_w = class({})

if IsServer() then
	function modifier_slark_w:OnCreated() 
		local hero = self:GetAbility():GetCaster():GetParentEntity()
        self.particle = FX("particles/units/heroes/hero_slark/slark_dark_pact_start.vpcf", PATTACH_CUSTOMORIGIN, hero:GetUnit(), {
            cp1 = {ent = hero:GetUnit()}
        })
	end
end

function modifier_slark_w:AllowAbilityEffect(source,ability)
	local hero = self:GetAbility():GetCaster():GetParentEntity()
	if not IsAttackAbility(ability) and source.owner.team ~= hero.owner.team then
		if not instanceof(source, ProjectilePudgeQ) then
			if instanceof(source, Projectile) and source:Alive() and source.destroyFunction then
				return false
			end
		else
			if source.goingBack then
				source:Destroy()
			end
		end

		return false,
		self:GoBang()
	end
end

function modifier_slark_w:GoBang()
	local hero = self:GetAbility():GetCaster():GetParentEntity()
    FX("particles/units/heroes/hero_slark/slark_dark_pact_pulses.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero:GetUnit(), {
        cp1 = {ent = hero:GetUnit()},
        cp2 = Vector(0,0,300)
    })

    hero:GetUnit():StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_1, 1.5)

    hero:AreaEffect({
        ability = self:GetAbility(),
        filter = Filters.Area(hero:GetPos(), 300),
        damage = self:GetAbility():GetDamage(),
        filterProjectiles = true
    })

    ParticleManager:DestroyParticle(self.particle, true)
    ParticleManager:ReleaseParticleIndex(self.particle)

    hero:EmitSound("Arena.Slark.CastW")
    self:Destroy()	
end
