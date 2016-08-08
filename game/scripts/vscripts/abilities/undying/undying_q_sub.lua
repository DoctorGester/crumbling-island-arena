undying_q_sub = class({})

function undying_q_sub:OnAbilityPhaseStart( ... )
    self:GetCaster():EmitSound("Arena.Undying.PreQ.Sub")
    return true
end

function undying_q_sub:OnSpellStart()
    Wrappers.DirectionalAbility(self)

    local hero = self:GetCaster().hero
    local direction = self:GetDirection()
    local hit = hero:AreaEffect({
        filter = Filters.Cone(hero:GetPos(), 350, direction, math.pi),
        sound = "Arena.Undying.HitQ.Sub",
        damage = true
    })

    if hit then
        hero:EmitSound("Arena.Undying.CastQ.Sub")
    end

    ScreenShake(hero:GetPos(), 5, 150, 0.45, 3000, 0, true)
end

function undying_q_sub:GetCastAnimation()
    return ACT_DOTA_ATTACK
end

function undying_q_sub:GetPlaybackRateOverride()
    return 2.0
end