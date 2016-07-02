invoker_w = class({})
LinkLuaModifier("modifier_invoker_w", "abilities/invoker/modifier_invoker_w", LUA_MODIFIER_MOTION_NONE)

function invoker_w:OnSpellStart()
    Wrappers.DirectionalAbility(self, 1000)

    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()

    DistanceCappedProjectile(hero.round, {
        owner = hero,
        from = hero:GetPos() + Vector(0, 0, 128),
        to = target + Vector(0, 0, 128),
        speed = 1200,
        graphics = "particles/invoker_w/invoker_w.vpcf",
        distance = 1000,
        hitSound = "Arena.Invoker.HitW",
        hitModifier = { name = "modifier_invoker_w", duration = 1.8, ability = self },
        hitFunction = function() end
    }):Activate()

    hero:EmitSound("Arena.Invoker.CastW")
end

function invoker_w:GetCastAnimation()
    return ACT_DOTA_ATTACK2
end

function invoker_w:GetPlaybackRateOverride()
    return 1.5
end