ta_q = class({})
LinkLuaModifier("modifier_ta_q", "abilities/ta/modifier_ta_q", LUA_MODIFIER_MOTION_NONE)

function ta_q:OnChannelThink(interval)
    self.timePassed = (self.timePassed or 0) + interval

    local hero = self:GetCaster():GetParentEntity()

    if interval == 0 then
        local path = hero:GetMappedParticle("particles/units/heroes/hero_templar_assassin/templar_assassin_meld.vpcf")
        self.particle = FX(path, PATTACH_ABSORIGIN_FOLLOW, hero, {
            cp1 = { ent = hero, attach = PATTACH_ABSORIGIN_FOLLOW },
            release = false
        })

        hero:EmitSound("Arena.TA.CastQ")
    end

    if self.timePassed > 0.3 and not self.animationStarted then
        hero:Animate(ACT_DOTA_CAST_ABILITY_4, 2.0)

        self.animationStarted = true
    end

    if (not self.animationStarted and self.timePassed < 0.2) or self.timePassed > 0.35 then
        hero:SetFacing(self:GetDirection())
    end
end

function ta_q:OnChannelFinish(interrupted)
    self.timePassed = 0
    self.animationStarted = false

    if self.particle then
        ParticleManager:DestroyParticle(self.particle, false)
        ParticleManager:ReleaseParticleIndex(self.particle)
    end

    if interrupted then
        return
    end

    local hero = self:GetCaster():GetParentEntity()
    local target = self:GetCursorPosition()

    DistanceCappedProjectile(hero.round, {
        owner = hero,
        from = hero:GetPos() + Vector(0, 0, 128),
        to = target + Vector(0, 0, 128),
        speed = 1550,
        graphics = hero:GetMappedParticle("particles/ta_q/ta_q.vpcf"),
        distance = 750,
        hitModifier = { name = "modifier_ta_q", duration = 3.0, ability = self },
        hitSound = "Arena.TA.HitQ",
        damage = self:GetDamage()
    }):Activate()

    hero:EmitSound("Arena.TA.CastQ2")

    if hurt and hero:HasModifier("modifier_ta_r_shield") then
        hero:FindAbility("ta_e"):EndCooldown()
    end
end

function ta_q:GetChannelTime()
    return 0.7
end

function ta_q:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_2
end

function ta_q:GetPlaybackRateOverride()
    return 1.5
end

if IsServer() then
    Wrappers.GuidedAbility(ta_q, true, true)
end