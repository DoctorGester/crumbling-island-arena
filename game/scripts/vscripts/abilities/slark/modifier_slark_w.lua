modifier_slark_w = class({})

if IsServer() then
    function modifier_slark_w:OnCreated()
        local hero = self:GetAbility():GetCaster():GetParentEntity()
        hero:FindAbility("slark_w"):SetActivated(false)
        self.particle = FX("particles/units/heroes/hero_slark/slark_dark_pact_start.vpcf", PATTACH_CUSTOMORIGIN, hero:GetUnit(), {
            cp1 = {ent = hero:GetUnit()}
        })
    end

    function modifier_slark_w:OnDestroy()
        local ability = self:GetParent():GetParentEntity():FindAbility("slark_w")
        ability:SetActivated(true)
        ability:StartCooldown(ability:GetCooldown(1))
        if self.particle then
	        ParticleManager:DestroyParticle(self.particle, false)
	        ParticleManager:ReleaseParticleIndex(self.particle)
	    end
    end
end

function modifier_slark_w:AllowAbilityEffect(source,ability)
    local hero = self:GetAbility():GetCaster():GetParentEntity()
    local exceptions = { ["sven_q"] = true, ["wr_r"] = true }
    if not IsAttackAbility(ability) and source.owner.team ~= hero.owner.team then
        if not instanceof(source, ProjectilePudgeQ) then
            if instanceof(source, Projectile) and source:Alive() and exceptions[ability:GetName()] then
                return false
            end
        else
            if source.goingBack then
                source:Destroy()
            end
        end

        self:GoBang()
        return false
    end
end

function modifier_slark_w:GoBang()
    local hero = self:GetAbility():GetCaster():GetParentEntity()
    FX("particles/units/heroes/hero_slark/slark_dark_pact_pulses.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero:GetUnit(), {
        cp1 = {ent = hero:GetUnit()},
        cp2 = Vector(0,0,300)
    })

    hero:GetUnit():StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_1, 1.5)

    ParticleManager:DestroyParticle(self.particle, true)
	ParticleManager:ReleaseParticleIndex(self.particle)
	self.particle = nil
    self:Destroy()

    hero:AreaEffect({
        ability = self:GetAbility(),
        filter = Filters.Area(hero:GetPos(), 300),
        damage = self:GetAbility():GetDamage(),
        filterProjectiles = true
    })

    hero:EmitSound("Arena.Slark.CastW")
end
