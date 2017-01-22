wr_q = class({})

function wr_q:OnChannelThink(interval)
    if interval == 0 then
        self:GetCaster():GetParentEntity():EmitSound("Arena.WR.PreQ")
    end
end

function wr_q:OnChannelFinish(interrupted)
    local hero = self:GetCaster():GetParentEntity()

    hero:StopSound("Arena.WR.PreQ")

    if interrupted then
        return
    end

    local target = self:GetCursorPosition()

    hero:Animate(ACT_DOTA_OVERRIDE_ABILITY_2, 1.5)
    hero:EmitSound("Arena.WR.CastQ")

    DistanceCappedProjectile(hero.round, {
        ability = self,
        owner = hero,
        from = hero:GetPos() + Vector(0, 0, 128),
        to = target + Vector(0, 0, 128),
        speed = 3500,
        distance = 1800,
        graphics = "particles/wr_q/wr_q.vpcf",
        damage = self:GetDamage(),
        hitSound = "Arena.WR.HitQ",
        continueOnHit = true
    }):Activate()

    ScreenShake(hero:GetPos(), 5, 150, 0.25, 3000, 0, true)
end

function wr_q:GetChannelTime()
    return 0.7
end

function wr_q:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_2
end

function wr_q:GetPlaybackRateOverride()
    return 1.3
end

if IsServer() then
    Wrappers.GuidedAbility(wr_q, true)
end