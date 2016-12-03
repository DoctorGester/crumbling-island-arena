pudge_a = class({})
LinkLuaModifier("modifier_pudge_a", "abilities/pudge/modifier_pudge_a", LUA_MODIFIER_MOTION_NONE)

function pudge_a:OnSpellStart()
    Wrappers.DirectionalAbility(self)

    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()
    local dir = self:GetDirection()
    dir = Vector(-dir.y, dir.x)

    DistanceCappedProjectile(hero.round, {
        owner = hero,
        from = hero:GetPos() + Vector(0, 0, 96) + dir * 80,
        to = target + Vector(0, 0, 96) + dir * 80,
        damage = self:GetDamage(),
        speed = 1450,
        radius = 48,
        graphics = "particles/pudge_a/pudge_a.vpcf",
        distance = 1200,
        hitModifier = { name = "modifier_pudge_a", duration = 1.8, ability = self },
        hitSound = "Arena.Pudge.HitA",
        screenShake = { 5, 150, 0.15, 3000, 0, true },
        isPhysical = true
    }):Activate()

    hero:EmitSound("Arena.Pudge.CastA")
end

function pudge_a:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_3
end

function pudge_a:GetPlaybackRateOverride()
    return 3
end

if IsClient() then
    require("wrappers")
end

Wrappers.AttackAbility(pudge_a)