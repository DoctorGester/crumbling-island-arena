pa_q = class({})

LinkLuaModifier("modifier_pa_q", "abilities/pa/modifier_pa_q", LUA_MODIFIER_MOTION_NONE)

function pa_q:OnSpellStart()
    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()

    DistanceCappedProjectile(hero.round, {
        ability = self,
        owner = hero,
        from = hero:GetPos() + Vector(0, 0, 64),
        to = target + Vector(0, 0, 64),
        speed = 1400,
        graphics = "particles/pa_w_sub/pa_w_sub.vpcf",
        distance = 900,
        hitModifier = { name = "modifier_pa_q", duration = 1.0, ability = self },
        hitSound = "Arena.PA.HitW.Sub",
        damage = self:GetDamage()
    }):Activate()

    hero:EmitSound("Arena.PA.CastW.Sub")
end

function pa_q:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_1
end