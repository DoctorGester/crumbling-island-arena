drow_a = class({})

function drow_a:OnSpellStart()
    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()

    DistanceCappedProjectile(hero.round, {
        ability = self,
        owner = hero,
        from = hero:GetPos() + Vector(0, 0, 64),
        to = target + Vector(0, 0, 64),
        damage = self:GetDamage(),
        speed = 2000,
        radius = 48,
        graphics = "particles/drow_q/drow_q.vpcf",
        distance = 1200,
        hitSound = "Arena.Drow.HitA",
        isPhysical = true,
        continueOnHit = true
    }):Activate()

    hero:EmitSound("Arena.Drow.CastQ2")
end

function drow_a:GetCastAnimation()
    return ACT_DOTA_ATTACK
end

function drow_a:GetPlaybackRateOverride()
    return 4
end

if IsClient() then
    require("wrappers")
end

Wrappers.AttackAbility(drow_a)