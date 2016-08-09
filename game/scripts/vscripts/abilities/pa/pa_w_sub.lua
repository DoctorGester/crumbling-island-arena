pa_w_sub = class({})

LinkLuaModifier("modifier_pa_w_sub", "abilities/pa/modifier_pa_w_sub", LUA_MODIFIER_MOTION_NONE)

function pa_w_sub:OnSpellStart()
    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()

    DistanceCappedProjectile(hero.round, {
        owner = hero,
        from = hero:GetPos() + Vector(0, 0, 64),
        to = target + Vector(0, 0, 64),
        speed = 1200,
        graphics = "particles/pa_w_sub/pa_w_sub.vpcf",
        distance = 1200,
        hitModifier = { name = "modifier_pa_w_sub", duration = 2.0, ability = self },
        hitSound = "Arena.PA.HitW.Sub",
        hitFunction = function() end
    }):Activate()

    hero:EmitSound("Arena.PA.CastW.Sub")
end

function pa_w_sub:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_1
end