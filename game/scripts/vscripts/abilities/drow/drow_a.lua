drow_a = class({})
LinkLuaModifier("modifier_drow_a", "abilities/drow/modifier_drow_a", LUA_MODIFIER_MOTION_NONE)

function drow_a:OnSpellStart()
    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()

    DistanceCappedProjectile(hero.round, {
        owner = hero,
        from = hero:GetPos() + Vector(0, 0, 64),
        to = target + Vector(0, 0, 64),
        damage = self:GetDamage(),
        speed = 1450,
        radius = 48,
        graphics = "particles/drow_a/drow_a.vpcf",
        distance = 1200,
        hitModifier = { name = "modifier_drow_a", duration = 0.45, ability = self },
        hitSound = "Arena.Drow.HitA"
    }):Activate()

    hero:EmitSound("Arena.Drow.CastA")
end

function drow_a:GetCastAnimation()
    return ACT_DOTA_ATTACK
end

function drow_a:GetPlaybackRateOverride()
    return 3
end

Wrappers.AttackAbility(drow_a)