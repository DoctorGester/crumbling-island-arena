drow_q = class({})
LinkLuaModifier("modifier_drow_q", "abilities/drow/modifier_drow_q", LUA_MODIFIER_MOTION_NONE)

function drow_q:OnSpellStart()
    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()

    DistanceCappedProjectile(hero.round, {
        owner = hero,
        from = hero:GetPos() + Vector(0, 0, 64),
        to = target + Vector(0, 0, 64),
        speed = 1450,
        radius = 48,
        graphics = "particles/drow_q/drow_q.vpcf",
        distance = 1200,
        hitModifier = { name = "modifier_drow_q", duration = 1.5, ability = self },
        hitSound = "Arena.Drow.HitQ"
    }):Activate()

    hero:EmitSound("Arena.Drow.CastQ")
end

function drow_q:GetCastAnimation()
    return ACT_DOTA_ATTACK
end

function drow_q:GetPlaybackRateOverride()
    return 3
end