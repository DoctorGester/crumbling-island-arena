venge_a = class({})

function venge_a:OnSpellStart()
    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()

    DistanceCappedProjectile(hero.round, {
        owner = hero,
        from = hero:GetPos() + Vector(0, 0, 64),
        to = target + Vector(0, 0, 64),
        damage = self:GetDamage(),
        speed = 1450,
        radius = 48,
        graphics = "particles/venge_a/venge_a.vpcf",
        distance = 1000,
        hitSound = "Arena.Venge.HitA",
        isPhysical = true
    }):Activate()

    hero:EmitSound("Arena.Venge.CastA")
end

function venge_a:GetCastAnimation()
    return ACT_DOTA_ATTACK
end

function venge_a:GetPlaybackRateOverride()
    return 2.5
end

if IsClient() then
    require("wrappers")
end

Wrappers.AttackAbility(venge_a)