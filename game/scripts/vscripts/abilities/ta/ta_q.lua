ta_q = class({})
LinkLuaModifier("modifier_ta_q", "abilities/ta/modifier_ta_q", LUA_MODIFIER_MOTION_NONE)

function ta_q:OnSpellStart(interrupted)
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
        speed = 1250,
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

function ta_q:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_3
end

function ta_q:GetPlaybackRateOverride()
    return 2.0
end